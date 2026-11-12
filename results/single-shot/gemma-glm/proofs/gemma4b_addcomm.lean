import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a with
  | 0 =>
    simp [Nat.zero_add, Nat.succ_add, Nat.succ_zero]
  | succ a' =>
    simp [Nat.succ_add, Nat.succ_zero, Nat.zero_add]
