import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction a with a' ih
  · have := a' + b + c = a' + (b + c)
    simp [add_assoc b c]
    exact have
  · have := (a' + 1) + b + c = a' + (b + c)
    simp [add_assoc a' b c, add_assoc a' b c]
    exact have
