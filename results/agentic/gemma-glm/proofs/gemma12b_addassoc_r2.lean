import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction a with
  | zero =>
    simp
  | succ a' ih =>
    simp [add_succ, ih]
