import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a :=
by
  induction a with
  | zero => rw [Nat.add_zero], refl
  | succ a =>
    rw [Nat.add_succ] at lhs
    rw [Nat.add_succ] at rhs
    exact add_comm_test a b
