import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction c with
  | zero => 
    rw [Nat.add_zero, Nat.add_zero]
  | succ c => 
    rw [Nat.add_succ, Nat.add_succ]
    rw [h]
