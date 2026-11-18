import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a with | zero { exact nat.zero_add b }
                 | succ h { rw [nat.succ_add, nat.add_succ, h] }
