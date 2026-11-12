import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  exact Nat.add_assoc a b c
