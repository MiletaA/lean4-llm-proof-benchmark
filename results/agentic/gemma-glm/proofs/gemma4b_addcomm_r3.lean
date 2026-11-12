import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  cases a
  simp [Nat.zero_add, add_zero, Nat.succ_add]
  rw [Nat.succ_add, add_zero]
  cases b
  simp [Nat.zero_add, add_zero, Nat.succ_add]
  rw [Nat.succ_add, add_zero]
