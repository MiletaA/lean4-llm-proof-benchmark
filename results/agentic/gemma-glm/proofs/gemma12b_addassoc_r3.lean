import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction a with a' ih
  · simp
  · simp [add_succ_eq]
    apply ih
    simp
