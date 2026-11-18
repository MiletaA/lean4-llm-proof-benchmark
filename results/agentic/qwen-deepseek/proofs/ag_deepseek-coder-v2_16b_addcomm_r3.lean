import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a with | zero ih =>
    -- Base case: when `a` is zero
    { rw [Nat.zero_add, Nat.add_zero] }
  -- Inductive step: assume the property holds for some `a`, prove it for `a + 1`
  { cases b with | zero ih' =>
      -- Base case when `b` is zero
      { rw [Nat.add_zero, Nat.zero_add] }
    -- Inductive step: assume the property holds for some `b`, prove it for `b + 1`
    { rw [Nat.add_succ, Nat.add_succ, ih, ih'] } }
