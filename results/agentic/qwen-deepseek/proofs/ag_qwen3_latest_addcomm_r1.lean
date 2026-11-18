import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a
  case zero =>
    rw [Nat.add_zero, Nat.zero_add]
  case succ =>
    rw [Nat.add_succ, Nat.add_succ]
    apply Nat.succ_inj
    apply ih
