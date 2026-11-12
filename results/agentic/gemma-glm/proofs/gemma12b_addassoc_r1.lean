import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction a with a' ih
  · have h := a' + b = b + a'
    simp [add_comm]
    simp [add_assoc]
  · have h := (a' + 1) + b = a' + (1 + b)
    simp [add_assoc]
    reflexivity
