import Mathlib.Data.Nat.Basic

theorem add_comm_test (a b : ℕ) :
  a + b = b + a :=
by match a with
| 0 => rw [Nat.add_zero, Nat.zero_add] <;> rfl
| succ n ih =>
  have key := by exact ih
  cases b with | zero => rfl | succ m hj =>
    change (succ n) + (succ m) = (succ m) + (succ n)
    rw [← Nat.succ_inj, ← Nat.add_succ] at this goal
    exact key.trans hj
