import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a with | zero ih =>
    { rw [Nat.add_zero, Nat.zero_add] }
  | succ n ih' =>
    rw [Nat.add_succ, Nat.succ_add, ih']
