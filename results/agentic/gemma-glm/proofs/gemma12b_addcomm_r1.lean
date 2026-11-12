import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a with
    | zero =>
      simp
    | succ a' ih =>
      simp [Nat.succ_add, Nat.add_comm]
