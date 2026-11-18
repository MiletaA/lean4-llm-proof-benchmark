import Mathlib

-- Helper lemma to prove associativity of addition for natural numbers
lemma add_assoc (a b c : ℕ) : (a + b) + c = a + (b + c) := by
  induction c with
  | zero {
    -- Base case: when c is 0, the statement simplifies to (a + b) + 0 = a + (b + 0)
    rw add_zero (a + b)
    rw add_zero a
    exact rfl
  }
  | succ n ih {
    -- Inductive step: assume the property holds for c = n, prove it for c = n + 1
    rw add_succ (a + b) n
    rw add_succ a (b + n)
    rw ih
    exact rfl
  }

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  exact add_assoc a b c
