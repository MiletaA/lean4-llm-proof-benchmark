import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a
  case zero => rw [zero_add, add_zero]
  case succ a =>
    rw [add_succ]  -- rewrite (succ a) + b to succ (a + b)
    rw [inductive_hypothesis]  -- apply the inductive hypothesis to get succ (b + a)
    rw [add_succ]  -- rewrite b + succ a to succ (b + a)

lemma add_succ (a b : ℕ) : a + succ b = succ (a + b) := by
  induction a
  case zero => rw [zero_add]
  case succ a => rw [add_succ, add_succ]

lemma zero_add (a : ℕ) : 0 + a = a := by
  rw [add_zero]

lemma add_zero (a : ℕ) : a + 0 = a := by
  rw [add_zero]
