import Mathlib

-- Helper lemma to prove addition associativity for natural numbers
lemma add_assoc_natural (m n p : ℕ) :
  m + (n + p) = (m + n) + p := by
  induction p with p ih,
  -- Base case: p = 0
  { simp [add_zero] },
  -- Inductive step: p + 1
  { have h : n + p = n + (p + 1) + 1 - 1, by simp [add_one],
    have h' : m + (n + p) = m + n + p, by simp,
    have h'' : m + n + p + 1 = m + n + (p + 1), by simp [h],
    rw [h', ih, add_assoc_natural] at h'',
    exact h'' }

-- Now we can prove the original theorem using our helper lemma
theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  apply add_assoc_natural
