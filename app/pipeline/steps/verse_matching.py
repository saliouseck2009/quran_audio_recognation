"""
Verse Matching Step - Step 7 of the pipeline.

Matches transcribed text to Quran verses.
"""

from app.pipeline.base import PipelineStep, PipelineContext
import quran_ayah_lookup as qal
from rapidfuzz import fuzz, process
from difflib import SequenceMatcher

class VerseMatchingStep(PipelineStep):
    """
    Match transcription to Quran verses.
    
    Input (from context):
        - final_transcription: Combined transcription
        - chunks: Chunk boundaries (for hints)
    
    Output (to context):
        - matched_verses: List of matched verses
    
    Note: Implement your own verse matching logic here.
    """
    
    def __init__(
        self,
        similarity_threshold: float = 0.70,
        min_word_match_ratio: float = 0.75,
        multi_chunk_similarity_floor: float = 0.60,
        multi_ayah_similarity_threshold: float = 0.70,
        multi_ayah_word_tolerance: int = 2,
        allow_low_confidence_fallback: bool = True,
    ):
        """
        Initialize verse matching step.
        """
        super().__init__()
        # Similarity threshold for SequenceMatcher fallback.
        self.SIMILARITY_THRESHOLD = similarity_threshold
        # Ratio-based tolerance: 0.75 means "at least 75% words match".
        self.MIN_WORD_MATCH_RATIO = min_word_match_ratio
        # Lower floor used when testing multi-chunk combinations.
        self.MULTI_CHUNK_SIMILARITY_FLOOR = multi_chunk_similarity_floor
        # Multi-ayah special-case similarity cutoff.
        self.MULTI_AYAH_SIMILARITY_THRESHOLD = multi_ayah_similarity_threshold
        # Allowed extra words when trying to fit several ayahs in one chunk.
        self.MULTI_AYAH_WORD_TOLERANCE = multi_ayah_word_tolerance
        # If True, never fail hard when a verse was detected globally.
        # We return best-effort verse mapping with lower confidence.
        self.ALLOW_LOW_CONFIDENCE_FALLBACK = allow_low_confidence_fallback

    @staticmethod
    def _word_match_ratio(reference_text: str, candidate_text: str) -> float:
        """
        Compute word-level similarity ratio between verse text and candidate chunk text.
        """
        reference_words = reference_text.split()
        candidate_words = candidate_text.split()

        if not reference_words and not candidate_words:
            return 1.0
        if not reference_words or not candidate_words:
            return 0.0

        return SequenceMatcher(None, reference_words, candidate_words).ratio()

    def _build_fallback_chunk_mapping(
        self,
        verses_in_range: list,
        cleaned_transcriptions: list,
        global_similarity: float,
    ) -> list:
        """
        Build a best-effort chunk mapping when strict mapping fails.
        """
        if not verses_in_range:
            return []

        fallback_entries = []
        if not cleaned_transcriptions:
            # No chunks available: still return ayah metadata with zero timing.
            for verse in verses_in_range:
                fallback_entries.append({
                    'chunk_index': -1,
                    'chunk_start_time': 0.0,
                    'chunk_end_time': 0.0,
                    'chunk_text': '',
                    'chunk_normalized_text': '',
                    'matched_ayahs': [{
                        'surah_number': verse['surah_number'],
                        'ayah_number': verse['ayah_number'],
                        'text': verse['text'],
                        'text_normalized': verse['text_normalized'],
                        'is_basmalah': verse['is_basmalah'],
                        'start_from_word': verse.get('start_from_word', 1),
                        'end_to_word': verse.get('end_to_word', verse['word_count']),
                        'similarity': global_similarity,
                    }],
                    'similarity': global_similarity,
                    'fallback_mapping': True,
                })
            return fallback_entries

        # Map one verse to one closest chunk; if verses > chunks reuse last chunk.
        for idx, verse in enumerate(verses_in_range):
            chunk = cleaned_transcriptions[min(idx, len(cleaned_transcriptions) - 1)]
            fallback_entries.append({
                'chunk_index': chunk.get('chunk_index'),
                'chunk_start_time': chunk.get('start_time'),
                'chunk_end_time': chunk.get('end_time'),
                'chunk_text': chunk.get('text'),
                'chunk_normalized_text': chunk.get('normalized_text', ''),
                'matched_ayahs': [{
                    'surah_number': verse['surah_number'],
                    'ayah_number': verse['ayah_number'],
                    'text': verse['text'],
                    'text_normalized': verse['text_normalized'],
                    'is_basmalah': verse['is_basmalah'],
                    'start_from_word': verse.get('start_from_word', 1),
                    'end_to_word': verse.get('end_to_word', verse['word_count']),
                    'similarity': global_similarity,
                }],
                'similarity': global_similarity,
                'fallback_mapping': True,
            })

        return fallback_entries

    def _finalize_chunk_mapping(
        self,
        context: PipelineContext,
        matched_chunk_verses: list,
        matched_ayahs: list,
        match_boundaries: dict,
        best_match,
        results: list,
        mapping_mode: str = "strict",
        fallback_reason: str = "",
    ) -> PipelineContext:
        """
        Store chunk mapping output in context and attach debug info.
        """
        context.matched_chunk_verses = matched_chunk_verses
        self.logger.info(f"Mapped {len(matched_chunk_verses)} chunks to verses")

        debug_payload = {
            'total_verses': len(matched_ayahs),
            'similarity': best_match.similarity,
            'matched_ayahs': matched_ayahs,
            'match_boundaries': match_boundaries,
            'matched_text': best_match.matched_text,
            'query_text': best_match.query_text,
            'total_results': len(results),
            'matched_chunk_verses': matched_chunk_verses,
            'total_mapped_chunks': len(matched_chunk_verses),
            'mapping_mode': mapping_mode,
        }
        if fallback_reason:
            debug_payload['fallback_reason'] = fallback_reason

        context.add_debug_info(self.name, debug_payload)
        return context
    
    def validate_input(self, context: PipelineContext) -> bool:
        """Validate that transcription is present."""
        if not context.final_transcription:
            self.logger.error("No final transcription in context")
            return False
        return True
    
    def process(self, context: PipelineContext) -> PipelineContext:
        """
        Match transcribed audio to Quran verses and map chunks to verses.
        
        Logic Flow:
        1. Search Quran for best matching verses using combined transcription
        2. Extract verse details and boundaries from best match
        3. Map audio chunks to verses using word-count based matching
        4. Validate that each verse reaches the required word-match ratio
        
        Returns:
            Context with matched_chunk_verses containing chunk-to-verse mappings
        """
        # Step 1: Search for matching verses in the Quran
        # Use the combined normalized transcription to find the best match
        ctn = context.combined_transcription_normalized
        self.logger.info(f"Matching verses for transcription ({len(ctn)} chars)...")
        
        # qal.search_sliding_window returns a list of potential matches with:
        # - verses: List of QuranVerse objects (surah_number, ayah_number, text, text_normalized, is_basmalah)
        # - similarity: Match score (0.0-100.0)
        # - matched_text: The Quran text that matched
        # - query_text: The transcription text used for search
        # - boundaries: start/end surah, ayah, and word positions
        results = qal.search_sliding_window(ctn)
        
        # Step 2: Handle no matches case
        if not results:
            self.logger.warning("No verse matches found")
            context.matched_verses = []
            context.match_similarity = 0.0
            context.match_boundaries = {}
            return context
        
        # Step 3: Select the best match (highest similarity score)
        best_match = max(results, key=lambda r: r.similarity)
        self.logger.info(f"Best match found with {best_match.similarity:.2f}% similarity")


        # Step 3.5: Sort verses by surah number first, then ayah number
        sorted_best_match = sorted(best_match.verses, key=lambda v: (v.surah_number, v.ayah_number))
        
        # If transcription starts with basmalah, ensure match also starts with basmalah
        # Remove all ayahs before the basmalah
        if ctn.startswith("بسم الله الرحمن الرحيم"):
            # Find the index of the first basmalah
            basmalah_index = None
            for i, verse in enumerate(sorted_best_match):
                if verse.is_basmalah:
                    basmalah_index = i
                    break
            
            # Keep only verses from basmalah onwards
            if basmalah_index is not None:
                sorted_best_match = sorted_best_match[basmalah_index:]
                self.logger.info(f"Transcription starts with basmalah, removed {basmalah_index} ayahs before basmalah")
            else:
                self.logger.warning("Transcription starts with basmalah but no basmalah found in match")

        best_match.verses = sorted_best_match
        
        # Step 4: Extract verse details from the best match
        # Convert QuranVerse objects to dictionaries for easier handling
        matched_ayahs = []
        for verse in best_match.verses:
            ayah_data = {
                'surah_number': verse.surah_number,
                'ayah_number': verse.ayah_number,
                'text': verse.text,  # Original text with diacritics
                'text_normalized': verse.text_normalized,  # Normalized text without diacritics
                'is_basmalah': verse.is_basmalah
            }
            matched_ayahs.append(ayah_data)
        
        # Step 5: Extract match boundaries (which part of the Quran was matched)
        match_boundaries = {
            'start_surah': best_match.start_surah,
            'start_ayah': best_match.start_ayah,
            'start_word': best_match.start_word,
            'end_surah': best_match.end_surah,
            'end_ayah': best_match.end_ayah,
            'end_word': best_match.end_word
        }
        
        # Step 6: Store match results in context for use by downstream steps
        context.matched_verses = best_match.verses  # Original verse objects
        context.matched_ayahs = matched_ayahs  # Extracted dictionaries
        context.match_similarity = best_match.similarity
        context.match_boundaries = match_boundaries
        context.matched_text = best_match.matched_text
        context.query_text = best_match.query_text
        
        self.logger.info(
            f"Matched {len(matched_ayahs)} ayahs from Surah {match_boundaries['start_surah']}:"
            f"{match_boundaries['start_ayah']} to Surah {match_boundaries['end_surah']}:"
            f"{match_boundaries['end_ayah']}"
        )
        
        # Step 7: Map audio chunks to verses using word-count based matching
        # This ensures each verse gets the correct chunks based on word count
        self.logger.info("Mapping chunks to verses using word-count matching...")
        
        # Get cleaned transcriptions (chunks with duplicates removed)
        cleaned_transcriptions = context.cleaned_transcriptions
        
        # Step 8: Prepare verses within the matched boundaries.
        # For first/last verses, apply start_word/end_word boundaries so we match
        # only the recited segment (not the full ayah text).
        verses_in_range = []
        start_position = (
            match_boundaries['start_surah'],
            match_boundaries['start_ayah'],
        )
        end_position = (
            match_boundaries['end_surah'],
            match_boundaries['end_ayah'],
        )

        for verse in best_match.verses:
            verse_position = (verse.surah_number, verse.ayah_number)
            
            if start_position <= verse_position <= end_position:
                verse_words = verse.text_normalized.split()
                start_idx = 0
                end_idx = len(verse_words)

                if verse_position == start_position:
                    raw_start_word = int(match_boundaries.get('start_word') or 1)
                    start_idx = max(0, min(len(verse_words), raw_start_word - 1))

                if verse_position == end_position:
                    raw_end_word = int(match_boundaries.get('end_word') or len(verse_words))
                    end_idx = max(start_idx, min(len(verse_words), raw_end_word))

                bounded_words = verse_words[start_idx:end_idx] if verse_words else []
                bounded_text_normalized = ' '.join(bounded_words).strip()
                if not bounded_text_normalized:
                    # Defensive fallback: if boundaries are out of range, keep full verse.
                    bounded_text_normalized = verse.text_normalized
                    bounded_words = verse_words

                verses_in_range.append({
                    'text_normalized': bounded_text_normalized,
                    'surah_number': verse.surah_number,
                    'ayah_number': verse.ayah_number,
                    'text': verse.text,
                    'is_basmalah': verse.is_basmalah,
                    'word_count': len(bounded_words),
                    'start_from_word': start_idx + 1,
                    'end_to_word': start_idx + len(bounded_words),
                })
        
        self.logger.info(f"Found {len(verses_in_range)} verses in range")
        
        # Step 9: Sequentially assign chunks to verses
        # Process verses in order, assigning chunks based on word count matching
        matched_chunk_verses = []
        chunk_index = 0  # Track current position in chunks list
        verse_idx = 0  # Manual index tracking to allow skipping verses
        
        while verse_idx < len(verses_in_range):
            verse = verses_in_range[verse_idx]
            verse_word_count = verse['word_count']
            verse_key = f"Surah {verse['surah_number']}:Ayah {verse['ayah_number']}"
            verse_start_chunk_index = chunk_index
            
            self.logger.debug(f"Processing {verse_key} ({verse_word_count} words)")
            
            # Step 10: Collect chunks for this verse.
            # Keep adding chunks until we reach the required word-match ratio.
            verse_chunks = []
            total_chunk_words = 0
            chunks_used = []  # For logging/debugging
            chunk_similarity_ratio = 0.0
            
            # Try sequential chunk accumulation first.
            while chunk_index < len(cleaned_transcriptions):
                chunk = cleaned_transcriptions[chunk_index]
                chunk_normalized = chunk.get('normalized_text', '')
                chunk_word_count = len(chunk_normalized.split())
                verse_chunks.append(chunk)
                chunks_used.append(
                    f"Chunk {chunk.get('chunk_index')} ({chunk_word_count} words)"
                )
                total_chunk_words += chunk_word_count
                chunk_index += 1

                combined_text = ' '.join(
                    c.get('normalized_text', '') for c in verse_chunks
                )
                chunk_similarity_ratio = self._word_match_ratio(
                    verse['text_normalized'],
                    combined_text,
                )

                if chunk_similarity_ratio >= self.MIN_WORD_MATCH_RATIO:
                    break

            # Step 11: Validate the match (ratio-based).
            final_difference = total_chunk_words - verse_word_count
            
            if chunk_similarity_ratio < self.MIN_WORD_MATCH_RATIO:
                # Ratio tolerance failed - try SequenceMatcher approach
                self.logger.warning(
                    f"Low word-match ratio for {verse_key}: {chunk_similarity_ratio:.2%} "
                    f"(required: {self.MIN_WORD_MATCH_RATIO:.2%}). Trying SequenceMatcher..."
                )
                
                # Try different chunk combinations using SequenceMatcher
                best_match_result = self._find_best_chunk_match(
                    verse['text_normalized'],
                    cleaned_transcriptions,
                    chunk_index - len(verse_chunks),  # Start from where we began
                    verse_word_count
                )
                
                if best_match_result:
                    # Found a better match using SequenceMatcher
                    verse_chunks = best_match_result['chunks']
                    total_chunk_words = best_match_result['total_words']
                    final_difference = total_chunk_words - verse_word_count
                    chunk_similarity_ratio = best_match_result['similarity']
                    chunks_used = [f"Chunk {c.get('chunk_index')} ({len(c.get('normalized_text', '').split())} words)" 
                                   for c in verse_chunks]
                    chunk_index = best_match_result['end_index']
                    
                    self.logger.info(
                        f"SequenceMatcher found better match: similarity={best_match_result['similarity']:.2%}, "
                        f"word_diff={final_difference}"
                    )
                else:
                    # Even SequenceMatcher couldn't find a good match
                    # Before failing, check if this is a case of multiple short ayahs in one chunk
                    multi_ayah_result = self._try_multi_ayah_in_single_chunk(
                        verse_idx,
                        verses_in_range,
                        verse_chunks,
                        cleaned_transcriptions,
                        chunk_index - len(verse_chunks)
                    )
                    
                    if multi_ayah_result:
                        # Successfully mapped multiple ayahs to single chunk
                        self.logger.info(
                            f"Special case: Mapped {multi_ayah_result['num_ayahs']} ayahs "
                            f"to single chunk {multi_ayah_result['chunk_index']}"
                        )
                        
                        # Add all the matched entries
                        matched_chunk_verses.extend(multi_ayah_result['matched_entries'])
                        
                        # Update chunk_index to move to next chunk
                        chunk_index = multi_ayah_result['next_chunk_index']
                        
                        # Skip all the verses we just processed
                        verse_idx += multi_ayah_result['verses_processed']
                        
                        # Continue to next iteration (skip normal processing)
                        continue
                    else:
                        # Really failed in strict mode.
                        error_msg = (
                            f"ERROR: Failed to match {verse_key} ({verse_word_count} words).\n"
                            f"Chunks used: {', '.join(chunks_used)}\n"
                            f"Total chunk words: {total_chunk_words}\n"
                            f"Difference: {final_difference} words\n"
                            f"Word-match ratio: {chunk_similarity_ratio:.2%} "
                            f"(required: {self.MIN_WORD_MATCH_RATIO:.2%})\n"
                            f"Verse text: {verse['text_normalized'][:100]}..."
                        )
                        if self.ALLOW_LOW_CONFIDENCE_FALLBACK:
                            self.logger.warning(
                                "Strict verse mapping failed; returning best-effort fallback mapping: %s",
                                error_msg.replace("\n", " | "),
                            )
                            remaining_verses = verses_in_range[verse_idx:]
                            remaining_chunks = cleaned_transcriptions[verse_start_chunk_index:]
                            fallback_entries = self._build_fallback_chunk_mapping(
                                verses_in_range=remaining_verses,
                                cleaned_transcriptions=remaining_chunks,
                                global_similarity=best_match.similarity,
                            )
                            return self._finalize_chunk_mapping(
                                context=context,
                                matched_chunk_verses=matched_chunk_verses + fallback_entries,
                                matched_ayahs=matched_ayahs,
                                match_boundaries=match_boundaries,
                                best_match=best_match,
                                results=results,
                                mapping_mode="fallback",
                                fallback_reason=error_msg,
                            )

                        self.logger.error(error_msg)
                        raise ValueError(error_msg)
            
            if not verse_chunks:
                # Error: No chunks available for this verse
                error_msg = (
                    f"ERROR: No chunks available for {verse_key} ({verse_word_count} words).\n"
                    f"All chunks may have been consumed by previous verses."
                )
                if self.ALLOW_LOW_CONFIDENCE_FALLBACK:
                    self.logger.warning(
                        "No chunks left for strict mapping; returning fallback mapping: %s",
                        error_msg.replace("\n", " | "),
                    )
                    remaining_verses = verses_in_range[verse_idx:]
                    remaining_chunks = cleaned_transcriptions[chunk_index:]
                    fallback_entries = self._build_fallback_chunk_mapping(
                        verses_in_range=remaining_verses,
                        cleaned_transcriptions=remaining_chunks,
                        global_similarity=best_match.similarity,
                    )
                    return self._finalize_chunk_mapping(
                        context=context,
                        matched_chunk_verses=matched_chunk_verses + fallback_entries,
                        matched_ayahs=matched_ayahs,
                        match_boundaries=match_boundaries,
                        best_match=best_match,
                        results=results,
                        mapping_mode="fallback",
                        fallback_reason=error_msg,
                    )

                self.logger.error(error_msg)
                raise ValueError(error_msg)
            
            # Step 12: Create matched verse entry
            # Store verse metadata for each chunk that belongs to this verse
            chunk_matched_ayahs = [{
                'surah_number': verse['surah_number'],
                'ayah_number': verse['ayah_number'],
                'text': verse['text'],
                'text_normalized': verse['text_normalized'],
                'is_basmalah': verse['is_basmalah'],
                'start_from_word': verse.get('start_from_word', 1),
                'end_to_word': verse.get('end_to_word', verse['word_count']),
                'similarity': chunk_similarity_ratio * 100
            }]
            
            # Step 13: Add entry for each chunk that belongs to this verse
            # Each chunk gets tagged with its verse information
            for chunk in verse_chunks:
                matched_chunk_verses.append({
                    'chunk_index': chunk.get('chunk_index'),
                    'chunk_start_time': chunk.get('start_time'),
                    'chunk_end_time': chunk.get('end_time'),
                    'chunk_text': chunk.get('text'),
                    'chunk_normalized_text': chunk.get('normalized_text', ''),
                    'matched_ayahs': chunk_matched_ayahs,
                    'similarity': chunk_similarity_ratio * 100
                })
            
            self.logger.info(
                f"{verse_key}: Matched {len(verse_chunks)} chunk(s), "
                f"total {total_chunk_words} words (verse: {verse_word_count} words, "
                f"diff: {final_difference:+d}, ratio: {chunk_similarity_ratio:.2%})"
            )
            
            # Move to next verse
            verse_idx += 1
        
        return self._finalize_chunk_mapping(
            context=context,
            matched_chunk_verses=matched_chunk_verses,
            matched_ayahs=matched_ayahs,
            match_boundaries=match_boundaries,
            best_match=best_match,
            results=results,
            mapping_mode="strict",
        )
    
    def _find_best_chunk_match(self, verse_text: str, chunks: list, start_idx: int, target_word_count: int) -> dict:
        """
        Find the best chunk combination for a verse using SequenceMatcher.
        
        This handles cases where a chunk starts in the middle of an ayah and extends
        to the middle/end of the next ayah. We try combining consecutive chunks
        until we find a good match or run out of chunks.
        
        Args:
            verse_text: The normalized verse text to match
            chunks: List of all chunks
            start_idx: Starting chunk index
            target_word_count: Target word count for the verse
            
        Returns:
            Dictionary with best match info or None if no good match found
        """
        # Try different chunk combinations - be aggressive and try up to all remaining chunks
        # This handles cases where chunks are split in the middle of ayahs
        max_chunks_to_try = len(chunks) - start_idx
        
        self.logger.debug(
            f"Trying to match verse ({target_word_count} words) using chunks {start_idx} to {start_idx + max_chunks_to_try - 1}"
        )
        
        best_match = None
        best_similarity = 0.0
        best_word_diff = float('inf')
        
        for num_chunks in range(1, max_chunks_to_try + 1):
            end_idx = start_idx + num_chunks
            if end_idx > len(chunks):
                break
            
            # Get chunks for this combination
            chunk_combination = chunks[start_idx:end_idx]
            
            # Combine chunk texts
            combined_text = ' '.join(c.get('normalized_text', '') for c in chunk_combination)
            total_words = len(combined_text.split())
            word_diff = abs(total_words - target_word_count)
            
            # Calculate similarity using SequenceMatcher
            matcher = SequenceMatcher(None, verse_text, combined_text)
            similarity = matcher.ratio()
            
            # Check if this is a better match
            # Prioritize: 1) High similarity, 2) Low word difference
            # Be more lenient when combining multiple chunks (partial ayahs case)
            is_better = False
            
            # Lower threshold for multi-chunk combinations (partial ayahs)
            effective_threshold = self.SIMILARITY_THRESHOLD
            if num_chunks > 1:
                # For partial ayah cases, accept a lower configurable floor.
                effective_threshold = max(
                    self.MULTI_CHUNK_SIMILARITY_FLOOR,
                    self.SIMILARITY_THRESHOLD - 0.1
                )
            
            if similarity >= effective_threshold:
                if best_match is None:
                    is_better = True
                elif similarity > best_similarity + 0.05:  # Significantly better similarity
                    is_better = True
                elif similarity >= best_similarity - 0.02 and word_diff < best_word_diff:
                    # Similar similarity but better word count
                    is_better = True
            
            if is_better:
                best_match = {
                    'chunks': chunk_combination,
                    'total_words': total_words,
                    'similarity': similarity,
                    'word_diff': word_diff,
                    'end_index': end_idx
                }
                best_similarity = similarity
                best_word_diff = word_diff
                
                self.logger.debug(
                    f"Candidate: {num_chunks} chunks, {total_words} words, "
                    f"similarity={similarity:.2%}, word_diff={word_diff}"
                )
        
        return best_match
    
    def _try_multi_ayah_in_single_chunk(self, current_verse_idx: int, verses_in_range: list, 
                                         current_chunks: list, all_chunks: list, 
                                         start_chunk_idx: int) -> dict:
        """
        Special case handler: Try to fit multiple short ayahs into a single chunk.
        This handles cases where one chunk contains multiple complete verses.
        
        Args:
            current_verse_idx: Index of current verse in verses_in_range
            verses_in_range: List of all verses to match
            current_chunks: Chunks currently assigned (likely just 1)
            all_chunks: All available chunks
            start_chunk_idx: Starting chunk index
            
        Returns:
            Dictionary with matched entries or None if not applicable
        """
        # Only applicable if we have exactly 1 chunk
        if len(current_chunks) != 1:
            return None
        
        chunk = current_chunks[0]
        chunk_text = chunk.get('normalized_text', '')
        chunk_word_count = len(chunk_text.split())
        
        # Check if chunk is significantly longer than current verse
        current_verse = verses_in_range[current_verse_idx]
        if chunk_word_count <= current_verse['word_count'] * 1.5:
            # Chunk is not significantly longer, not a multi-ayah case
            return None
        
        self.logger.info(
            f"Checking if chunk {chunk.get('chunk_index')} ({chunk_word_count} words) "
            f"contains multiple ayahs starting from verse {current_verse_idx}"
        )
        
        # Try to fit multiple consecutive verses into this chunk
        # This handles both complete and partial ayahs in the chunk
        matched_entries = []
        total_verse_words = 0
        verses_fitted = []
        
        for i in range(current_verse_idx, len(verses_in_range)):
            verse = verses_in_range[i]
            potential_total = total_verse_words + verse['word_count']
            
            # Check if adding this verse would still fit in the chunk
            if potential_total <= chunk_word_count + self.MULTI_AYAH_WORD_TOLERANCE:
                verses_fitted.append(verse)
                total_verse_words = potential_total
            else:
                # Can't fit more verses completely
                # But check if chunk contains the BEGINNING of this verse (partial match)
                if len(verses_fitted) >= 1:
                    # Try adding this verse as well (chunk may contain partial)
                    verses_fitted.append(verse)
                    total_verse_words = potential_total
                break
        
        # Need at least 2 verses to be a multi-ayah case
        if len(verses_fitted) < 2:
            return None
        
        # Check similarity between chunk and combined verses
        # The chunk may contain complete ayahs + partial next ayah
        combined_verse_text = ' '.join(v['text_normalized'] for v in verses_fitted)
        
        # Check if chunk matches the BEGINNING of combined verses (for partial matches)
        # Use SequenceMatcher to find the best alignment
        matcher = SequenceMatcher(None, chunk_text, combined_verse_text)
        similarity = matcher.ratio()
        
        # Also check if chunk is a prefix of combined verses (partial ayah case)
        chunk_words = chunk_text.split()
        combined_words = combined_verse_text.split()
        prefix_match = all(cw == vw for cw, vw in zip(chunk_words, combined_words[:len(chunk_words)]))
        
        if prefix_match:
            # Chunk is a perfect prefix of combined verses (partial ayah case)
            similarity = max(similarity, 0.85)  # Boost similarity for prefix matches
            self.logger.info(
                f"Chunk {chunk.get('chunk_index')} is a prefix match for {len(verses_fitted)} verses "
                f"(chunk: {len(chunk_words)} words, combined: {len(combined_words)} words)"
            )
        
        if similarity < self.MULTI_AYAH_SIMILARITY_THRESHOLD:
            self.logger.warning(
                f"Multi-ayah similarity too low: {similarity:.2%} for {len(verses_fitted)} verses"
            )
            return None
        
        # Check if we need additional chunks to complete the last ayah
        # This handles cases where an ayah is split across multiple chunks
        chunks_used = [chunk]
        next_chunk_idx = start_chunk_idx + 1
        
        # If the last verse is incomplete (chunk is shorter than expected), check next chunks
        last_verse = verses_fitted[-1]
        if chunk_word_count < total_verse_words:
            # The chunk doesn't contain all the words - last ayah is split
            words_needed = total_verse_words - chunk_word_count
            
            self.logger.info(
                f"Last ayah appears split across chunks. Need {words_needed} more words. "
                f"Checking next chunks..."
            )
            
            # Try to find the remaining words in subsequent chunks
            while next_chunk_idx < len(all_chunks) and words_needed > 0:
                next_chunk = all_chunks[next_chunk_idx]
                next_chunk_words = len(next_chunk.get('normalized_text', '').split())
                
                # Check if this chunk contains part of the last ayah
                # by checking if it matches the remaining text
                remaining_verse_text = ' '.join(last_verse['text_normalized'].split()[-words_needed:])
                next_chunk_text = next_chunk.get('normalized_text', '')
                
                # Check if next chunk starts with remaining verse text
                if next_chunk_text.startswith(remaining_verse_text.split()[0]):
                    chunks_used.append(next_chunk)
                    words_needed -= next_chunk_words
                    next_chunk_idx += 1
                    self.logger.info(
                        f"Added chunk {next_chunk.get('chunk_index')} to complete last ayah "
                        f"({next_chunk_words} words)"
                    )
                else:
                    break
        
        # Success! Create matched entries for all verses
        self.logger.info(
            f"Multi-ayah match confirmed: {len(verses_fitted)} verses across {len(chunks_used)} chunks, "
            f"{total_verse_words} words, similarity={similarity:.2%}"
        )
        
        for idx, verse in enumerate(verses_fitted):
            verse_key = f"Surah {verse['surah_number']}:Ayah {verse['ayah_number']}"
            
            matched_ayahs = [{
                'surah_number': verse['surah_number'],
                'ayah_number': verse['ayah_number'],
                'text': verse['text'],
                'text_normalized': verse['text_normalized'],
                'is_basmalah': verse['is_basmalah'],
                'similarity': similarity * 100
            }]
            
            if idx == 0:
                # First verse gets the full chunk timing
                matched_entries.append({
                    'chunk_index': chunk.get('chunk_index'),
                    'chunk_start_time': chunk.get('start_time'),
                    'chunk_end_time': chunk.get('end_time'),
                    'chunk_text': chunk.get('text'),
                    'chunk_normalized_text': chunk.get('normalized_text', ''),
                    'matched_ayahs': matched_ayahs,
                    'similarity': similarity * 100,
                    'chunk_reuse': False
                })
                self.logger.info(
                    f"{verse_key}: Primary ayah in multi-ayah chunk {chunk.get('chunk_index')}"
                )
            else:
                # Subsequent verses reuse the chunk with zero timing
                matched_entries.append({
                    'chunk_index': chunk.get('chunk_index'),
                    'chunk_start_time': 0.0,
                    'chunk_end_time': 0.0,
                    'chunk_text': chunk.get('text'),
                    'chunk_normalized_text': chunk.get('normalized_text', ''),
                    'matched_ayahs': matched_ayahs,
                    'similarity': similarity * 100,
                    'chunk_reuse': True  # Flag to indicate chunk is reused
                })
                self.logger.info(
                    f"{verse_key}: Reused chunk {chunk.get('chunk_index')} (chunk_reuse=True)"
                )
        
        return {
            'matched_entries': matched_entries,
            'num_ayahs': len(verses_fitted),
            'chunk_index': chunk.get('chunk_index'),
            'next_chunk_index': next_chunk_idx,  # Skip all chunks used
            'verses_processed': len(verses_fitted)
        }
