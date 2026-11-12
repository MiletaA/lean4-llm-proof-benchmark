import Mathlib

open Nat

/-! A helper lemma to prove that addition is commutative for natural numbers. -/

lemma add_comm (m n : ℕ) : m + n = n + m := by
  induction n with d hd
  · -- Base case: 0 + m
    rewrite [zero_add, hd]
  · -- Inductive step: m + (s k)
    cases k
    · -- Case k = 0
      rewrite [add_comm, hd]
    · -- Case k = s j
      apply congr_arg _ (hd)

/-! Now we can prove the associative property using the commutative property. -/

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction b with d hd
  · -- Base case: a + 0
    rewrite [zero_add, hd]
  · -- Inductive step: a + (s b')
    cases b'
    · -- Case b' = 0
      apply congr_arg _ zero_add
    · -- Case b' = s n
      induction c with d cd
        · -- Base case: c = 0
          rewrite [zero_add]
        · -- Inductive step: c = s c''
          have h : (a + (s b)) + 0 = a + (s b) := by rw zero_add
          have t : (a + (s b)) + (s c) = (a + (s b)) + c := by rw add_comm _ c
          rewrite [h, t]
      · -- Helper lemma application for addition being commutative
        have h' : s b + a = a + s b := hd
        -- Rewrite the expression using the helper lemma and the induction hypothesis
        apply congr_arg _ (add_assoc _ _ _)
