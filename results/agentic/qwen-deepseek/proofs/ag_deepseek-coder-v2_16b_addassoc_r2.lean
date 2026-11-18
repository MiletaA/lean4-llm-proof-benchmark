import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction a with | zero ih =>
    { rw [add_zero, add_zero], },
    { cases b with | zero bh =>
      { rw [add_zero, add_zero], },
      { cases c with | zero ch =>
        { rw [add_zero, add_zero], },
        { rw [add_succ (a + b) a b, add_succ a b (b + c), ih, add_succ a bh ch, add_assoc] }}}
