-- NHL Predictor Pro: enforce one prediction row per scheduled matchup.
-- IMPORTANT: this migration intentionally does not delete or rewrite historical rows.
-- First inspect and resolve duplicate groups using the query below. Then run this file.

-- Duplicate audit:
-- SELECT game_date, home_team, away_team, COUNT(*) AS row_count
-- FROM public.predictions
-- GROUP BY game_date, home_team, away_team
-- HAVING COUNT(*) > 1
-- ORDER BY game_date DESC, row_count DESC;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM public.predictions
    GROUP BY game_date, home_team, away_team
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION
      'Cannot create unique prediction index: duplicate game rows still exist. Review the duplicate audit query and preserve the original prediction before removing extras.';
  END IF;
END
$$;

CREATE UNIQUE INDEX IF NOT EXISTS predictions_one_row_per_game_idx
  ON public.predictions (game_date, home_team, away_team);
