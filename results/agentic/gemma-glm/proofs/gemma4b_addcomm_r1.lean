import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  rw [Nat.succ_add]
  rw [Nat.succ_add]
  rw [Nat.succ_add]
  rw [Nat.succ_add]
  rw [Nat.succ_add]
  simp
