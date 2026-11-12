import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  apply Nat.add_comm a b
