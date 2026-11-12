import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  rw [Nat.add_comm]
