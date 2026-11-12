import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction c with d hd,
  { refl },
  { rw [add_assoc, hd] }
