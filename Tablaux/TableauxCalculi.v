(* Imports *)
Require Import Bool List String Datatypes Omega Coq.Arith.Compare_dec Coq.Arith.Max.
Check max_dec.

(*
Definition PropVars : string.
Axiom Varseq_dec : forall x y : PropVars, {x = y} + {x <> y}.
*)

Definition optionBind (A B : Type) (f : A -> option B) (x : option A) :=
  match x with
  | None => None
  | Some v => (f v)
  end.

Inductive PropF : Type :=
 | Var : string -> PropF
 | Bot : PropF
 | Conj : PropF -> PropF -> PropF
 | Disj : PropF -> PropF -> PropF
 | Impl : PropF -> PropF -> PropF
.

Notation "# P" := (Var P) (at level 1).
Notation "A ∨ B" := (Disj A B) (at level 15, right associativity).
Notation "A ∧ B" := (Conj A B) (at level 15, right associativity).
Notation "A → B" := (Impl A B) (at level 16, right associativity).
Notation "⊥" := Bot (at level 0).
Definition Neg A := A → ⊥.
Notation "¬ A" := (Neg A) (at level 5).
Definition Top := ¬⊥.
Notation "⊤" := Top (at level 0).
Definition BiImpl A B := (A→B)∧(B→A).
Notation "A ↔ B" := (BiImpl A B) (at level 17, right associativity).

(* Defining equivalence for PropF *)
Fixpoint EquivPropF x y :=
  match (x, y) with
  | (# a, #b) => if string_dec a b then true else false
  | (⊥, ⊥) => true
  | (a1 ∧ a2, b1 ∧ b2) => andb (EquivPropF a1 b1) (EquivPropF a2 b2)
  | (a1 ∨ a2, b1 ∨ b2) => andb (EquivPropF a1 b1) (EquivPropF a2 b2)
  | (a1 → a2, b1 → b2) => andb (EquivPropF a1 b1) (EquivPropF a2 b2)
  | (_, _) => false
  end.

Fixpoint EquivPropV x y :=
  match (x, y) with
  | (# a, #b) => if string_dec a b then true else false
  | (# a, ⊥) => false
  | (# a, b1 ∧ b2) => orb (EquivPropV (# a) b1) (EquivPropV (# a) b2)
  | (# a, b1 ∨ b2) => orb (EquivPropV (# a) b1) (EquivPropV (# a) b2)
  | (# a, b1 → b2) => orb (EquivPropV (# a) b1) (EquivPropV (# a) b2)
  | (_, _) => false
  end.

(* Basic set of PropF *)
Definition PropFSet : Type := list PropF.

(* Possible Denom after proof search *)
Inductive Denom :=
  | Terminate
.

Theorem Denom_eq_dec : forall (r1 r2 : Denom), {r1=r2} + {r1<>r2}.
Proof.
  induction r1, r2.
  left; trivial.
Defined.

(* Defining a tableau rule *)
Definition Numerator := PropFSet.
Definition Denominator := sum (list PropFSet) Denom.

Check inr Terminate : Denominator.

Definition Rule := prod Numerator Denominator.

Definition getNumerator (rule : Rule) := fst rule.
Definition getDenominator (rule : Rule) := snd rule.

Definition TableauNode := sum PropFSet Denom.

Lemma propfDiscAnd1 : forall p: PropF, p ∧ p = p -> False.
intros.
  induction p; try discriminate H.
  inversion H. rewrite H1 in H2. rewrite H1 in H2. rewrite H2 in H1.
  auto.
Qed.

Lemma propfDiscAnd2 : forall p q: PropF, p ∧ q = p -> False.
intros.
  induction p; try discriminate H.
  inversion H. rewrite H2 in *. rewrite H1 in IHp1.
  apply IHp1. trivial.
Qed.

Print PropF_ind.

Print PropF.

Theorem PropF_eq_dec : forall (p q : PropF), {p = q} + {p <> q}.
Proof.
  intros. decide equality.
  apply string_dec.
Defined.
(*
  induction p, q; try (right; intuition; discriminate H).
  destruct (string_dec s s0). left. rewrite e; auto. right; intuition.
  inversion H; auto. left; trivial.
  destruct (IHp1 q1); destruct (IHp2 q2);
  subst;
  [(left; trivial) |
  right; subst; intuition; inversion H; auto |
  right; subst; intuition; inversion H; auto |
  right; subst; intuition; inversion H; auto].
  destruct (IHp1 q1); destruct (IHp2 q2);
  subst;
  [(left; trivial) |
  right; subst; intuition; inversion H; auto |
  right; subst; intuition; inversion H; auto |
  right; subst; intuition; inversion H; auto].
  destruct (IHp1 q1); destruct (IHp2 q2);
  subst;
  [(left; trivial) |
  right; subst; intuition; inversion H; auto |
  right; subst; intuition; inversion H; auto |
  right; subst; intuition; inversion H; auto].
Qed.
*)

Theorem PropFSet_eq_dec : forall (p1 p2 : PropFSet), {p1 = p2} + {p1 <> p2}.
Proof.
  intros. decide equality.
  apply PropF_eq_dec.
Defined.
(*
  induction p1, p2.
  left. trivial.
  right. intuition; discriminate H.
  right. intuition; discriminate H.
  destruct (PropF_eq_dec a p); destruct (IHp1 p2); subst; auto;
  right; intuition; inversion H; auto.
Qed.
*)

Theorem ListPropFSet_eq_dec : forall (l1 l2 : list PropFSet), {l1=l2} + {l1<>l2}.
Proof.
  intros. decide equality.
  apply PropFSet_eq_dec.
Defined.
(*
  induction l1, l2.
  left; trivial.
  right; intuition; discriminate H.
  right; intuition; discriminate H.
  destruct (PropFSet_eq_dec a p); destruct (IHl1 l2); subst.
  left; trivial.
  right; intuition; inversion H; auto.
  right; intuition; inversion H; auto.
  right; intuition; inversion H; auto.
Qed.
*)
Theorem Numerator_eq_dec : forall (n1 n2 : Numerator), {n1=n2} + {n1<>n2}.
Proof.
  intros. decide equality.
  apply PropF_eq_dec.
Defined.
(*
  unfold Numerator.
  exact PropFSet_eq_dec.
Qed.
*)

Theorem Denominator_eq_dec : forall (d1 d2 : Denominator), {d1=d2} + {d1<>d2}.
Proof.
  induction d1, d2.
  destruct (ListPropFSet_eq_dec a l); subst.
  left; trivial.
  right; intuition; inversion H; auto.
  right; intuition; discriminate H.
  right; intuition; discriminate H.
  left; destruct b, d; auto.
Defined.

Theorem Rule_eq_dec : forall (r1 r2 : Rule), {r1=r2} + {r1<>r2}.
Proof.
  induction r1, r2.
  destruct (Numerator_eq_dec a n); destruct (Denominator_eq_dec b d); subst;
  auto; right; intuition; inversion H; auto.
Defined.

(* Method to get propsitional variables *)
Fixpoint getPropVar (prop : PropF) :=
  match prop with
  | # pv => pv::nil
  | ⊥ => nil
  | a ∧ b => getPropVar a ++ getPropVar b
  | a ∨ b => getPropVar a ++ getPropVar b
  | a → b => getPropVar a ++ getPropVar b
  end.

Fixpoint getPropVars (props : PropFSet) :=
  match props with
  | nil => nil
  | x::xs => getPropVar x ++ getPropVars xs
  end.

Fixpoint isInstanceOf (formula : PropF) (scheme : PropF) :=
  match (formula, scheme) with
  | (_, #b) => true
  | (⊥, ⊥) => true
  | (a1 ∧ a2, b1 ∧ b2) => andb (isInstanceOf a1 b1) (isInstanceOf a2 b2)
  | (a1 ∨ a2, b1 ∨ b2) => andb (isInstanceOf a1 b1) (isInstanceOf a2 b2)
  | (a1 → a2, b1 → b2) => andb (isInstanceOf a1 b1) (isInstanceOf a2 b2)
  | (_, _) => false
  end.

Definition Partition := list (PropF * PropF).

(* Fix with fail monad or something ... *)
Fixpoint matchVarHelp (scheme : PropF) (γ : PropF) : Partition :=
  match (scheme, γ) with
  | (# pv, x) => (# pv, x)::nil
  | (⊥, ⊥) => nil
  | (a1 ∧ a2, b1 ∧ b2) => matchVarHelp a1 b1 ++ matchVarHelp a2 b2
  | (a1 ∨ a2, b1 ∨ b2) => matchVarHelp a1 b1 ++ matchVarHelp a2 b2
  | (a1 → a2, b1 → b2) => matchVarHelp a1 b1 ++ matchVarHelp a2 b2
  | (_, _) => nil
  end.

Definition matchVar (scheme : PropF) (γ : PropF) :=
  if isInstanceOf γ scheme then Some (matchVarHelp scheme γ)
  else None.

Recursive Extraction matchVar.

Compute (matchVar (# "p" → # "r") (⊥ → (# "q"))).

Fixpoint getSetVars (π : Partition) : PropFSet :=
  match π with
  | nil => nil
  | x::xs => (snd x) :: getSetVars xs
  end.

Compute getSetVars ((# "p", ⊥) :: (# "r", # "q") :: nil).

Fixpoint lookupPartition (γ : PropF) (π : Partition) :=
  match π with
  | nil => None
  | (v1, v2)::xs => if EquivPropF γ v1 then Some v2
                else lookupPartition γ xs
  end.

Fixpoint applyPartitionPropF (γ : PropF) (π : Partition) :=
  match lookupPartition γ π with
  | None => 
    match γ with
    | # pv => # pv
    | ⊥ => ⊥
    | a1 ∧ a2 => applyPartitionPropF a1 π ∧ applyPartitionPropF a2 π
    | a1 ∨ a2 => applyPartitionPropF a1 π ∨ applyPartitionPropF a2 π
    | a1 → a2 => applyPartitionPropF a1 π → applyPartitionPropF a2 π
    end
  | Some x => x
  end.

Fixpoint applyPartition (Γ : PropFSet) (π : Partition) :=
  match Γ with
  | nil => nil
  | x::xs => (applyPartitionPropF x π) :: (applyPartition xs π)
  end.

Compute (applyPartition ((# "p" → # "r")::nil) ((# "p", ⊥) :: (# "r", # "q") :: nil)).

Definition option_bind (A : Type) (B : Type) (x : option A) (f : A -> option B) :=
  match x with
  | None => None
  | Some v => f v
  end.

Definition flip (A : Type) (B : Type) (C : Type) 
  (f : B -> A -> C) (a : A) (b : B) := f b a.

Fixpoint option_fold (A : Type) (B : Type)
  (f : B -> A -> option B) (z : B) (l : list A) : option B :=
    match l with
    | nil => Some z
    | x::xs => option_bind B B (option_fold A B f z xs) (flip A B (option B) f x)
    end.

Fixpoint inPartitionTuple p (π : Partition) :=
  match π with
  | nil => false
  | x::xs => if andb (EquivPropF (fst x) (fst p)) (EquivPropF (snd x) (snd p))
              then true else inPartitionTuple p xs
  end.

Fixpoint usedVar (γ : PropF) (π : Partition) :=
  match π with
  | nil => false
  | x::xs => if (EquivPropV γ (snd x)) then true else usedVar γ xs
  end.

Fixpoint extendPartition (π1 π2 : Partition) :=
  match π2 with
  | nil => Some π1
  | x::xs => if inPartitionTuple x π1 then extendPartition π1 xs
              else (if usedVar (fst x) π1 then (if (EquivPropF (fst x) (snd x))
              then extendPartition π1 xs else None) else extendPartition (x::π1) xs)
  end.

Compute usedVar (#"a") ((# "p", # "a" ∨ # "b")::nil).
Compute extendPartition ((# "a", # "a")::nil) ((# "p", # "a" ∨ # "b")::nil).
Compute extendPartition ((# "p", # "a" ∨ # "b")::nil) ((# "a", # "a")::nil).
Compute extendPartition (nil) ((# "a", # "a")::nil).
Check matchVar.

Fixpoint partition_help (scheme : PropF) (Γ : PropFSet) (π : Partition) :=
  match Γ with
  | nil => nil
  | γ::γs =>
    match matchVar scheme γ with
    | None => partition_help scheme γs π
    | Some π' =>
      match extendPartition π π' with
      | None => partition_help scheme γs π
      | Some newπ => newπ :: partition_help scheme γs π
      end
    end
  end.

Check flat_map.

Definition lengthOrder (A : Type) (xs ys : list A) := length xs < length ys.

Lemma lengthOrder_wf : forall A, well_founded (lengthOrder A).
intros. unfold lengthOrder; unfold well_founded. induction a.
constructor. intros. simpl in H. omega. constructor.
intros. destruct (eq_nat_dec (length y) (length a0)).
constructor. intros. apply IHa. rewrite <- e. exact H0.
apply IHa. simpl in H. omega.
Defined.

Lemma unchanging : forall x π, length (applyPartition x π) <= length x.
Proof.
  induction x. intros. unfold applyPartition. trivial.
  simpl in *. intuition.
Qed.

(*
Definition getPartitions_help (schema : PropFSet) : PropFSet -> Partition -> list Partition.
  refine (Fix (lengthOrder_wf PropF) (fun _ => PropFSet -> Partition -> list Partition)
   (fun schema getPartitions_help_rec =>
   (match schema as schema' return (schema = schema' -> PropFSet -> Partition -> list Partition) with
    | nil => fun _ _ accπ => accπ::nil
    | s::ss => fun H Γ accπ => let Π := partition_help s Γ accπ in
        flat_map (fun π => getPartitions_help_rec (ss) _ Γ π) Π
    end) eq_refl) schema).
    rewrite H. assert (length (applyPartition ss π) <= length ss) by apply unchanging.
    unfold lengthOrder; simpl. omega.
    Defined.
*)

Fixpoint getPartitions_help (schema Γ : PropFSet) (acc : Partition) : list Partition :=
  match schema with
  | nil => acc :: nil
  | s::ss => flat_map (fun π => getPartitions_help ss Γ π) (partition_help s Γ acc)
  end.

Fixpoint filterpi (π : Partition) :=
  match π with
  | nil => nil
  | x::xs => if EquivPropF (fst x) (snd x) then filterpi xs else x::(filterpi xs)
  end.

Definition getPartitions schema Γ := (getPartitions_help schema Γ nil).

Check getPartitions.

Fixpoint removeFromSet remove Γ :=
  match Γ with
  | nil => nil
  | γ::γs => if EquivPropF γ remove then γs else γ::(removeFromSet remove γs)
  end.

Fixpoint removeMultSet (Remove Γ : PropFSet) : PropFSet :=
  match Remove with
  | nil => Γ
  | r::rs => removeMultSet rs (removeFromSet r Γ)
  end.

Check removeMultSet.

Print Denominator.
Print TableauNode.

Fixpoint denoApply (π : Partition) (d : Denominator) : list TableauNode :=
  match d with
  | inr s => (inr s) :: nil
  | inl lst => let mapApply a b := applyPartition b a in
               map inl (map (mapApply π) lst)
  end.

Check (app).

Fixpoint tableauAppend (Γ : PropFSet) (T : list TableauNode) : list TableauNode :=
  match T with
  | nil => nil
  | node::rest => match node with
                  | inr res => inr res :: tableauAppend Γ rest
                  | inl lst => inl (lst ++ Γ) :: tableauAppend Γ rest
                  end
  end.

Print TableauNode.

Fixpoint applyRule' (rule : Rule) (T : TableauNode) : option (list TableauNode) :=
  match T with
  | inr res => Some ((inr res) :: nil)
  | inl Γ => match (getPartitions (getNumerator rule) Γ) with
             | nil => None
             | π::πs => let inst := applyPartition (getNumerator rule) π in
                        let X := removeMultSet inst Γ in
                        Some (tableauAppend X (denoApply π (getDenominator rule)))
             end
  end.

Definition IdRule : Rule := (((# "p")::(¬(# "p"))::nil), ((inr Terminate)):Denominator).
Definition OrRule : Rule := (((# "p" ∨ # "q")::nil), (inl (((# "p")::nil)::((# "q")::nil)::nil))).
Definition AndRule : Rule := (((# "p" ∧ # "q")::nil), (inl (((# "p")::(# "q")::nil)::nil))).

Compute applyRule' IdRule (inl ((¬(#"a" ∨ #"b"))::(#"a" ∨ #"b")::(#"c" ∨ #"d")::(#"s")::nil)).
Compute applyRule' AndRule (inl ((¬(#"a" ∨ #"b"))::(#"a" ∧ #"b")::(#"c" ∨ #"d")::(#"s")::nil)).
Compute applyRule' OrRule (inl ((¬(#"a" ∨ #"b"))::(#"a" ∨ #"b")::(#"c" ∨ #"d")::(#"s")::nil)).
Compute applyRule' AndRule (inl ((¬(#"a" ∨ #"b"))::(#"a" ∨ #"b")::(#"c" ∨ #"d")::(#"s")::nil)).

Compute (getPartitions ((# "p")::(¬(# "p"))::nil) (((¬(#"a" ∨ #"b"))::(#"a" ∨ #"b")::(#"c" ∨ #"d")::(#"s")::nil))).
Compute (getPartitions ((# "p") :: nil) ((# "p") :: nil)).
Compute (extendPartition ((# "p", # "s") :: nil) ((# "s", ⊥)::nil) ).

Inductive DerTree :=
  | Clf : DerTree
  | Unf : PropFSet -> DerTree
  | Der : PropFSet -> Rule -> list DerTree -> DerTree
  .

Fixpoint DerTree_induction (PT : DerTree -> Type) (PL : list DerTree -> Type)
  (f_Clf : PT Clf) (f_Unf : forall x, PT (Unf x)) (f_Der : forall x r l, PL l -> PT (Der x r l))
  (g_nil : PL nil) (g_cons : forall x, PT x -> forall xs, PL xs -> PL (cons x xs)) 
  (t : DerTree) : PT t.
  destruct t; auto. 
  (* The only hard case is Der *)
  apply f_Der.
  (* Luckily we can use regular list induction to help *)
  induction l; auto.
  apply g_cons; auto.
  (* And since Coq knows this is a good recursive call, we're done *)
  apply (DerTree_induction PT PL); auto.
  Defined.

Theorem DerTree_eq_dec : forall (d1 d2 : DerTree), {d1=d2} + {d1 <> d2}.
Proof.
  induction d1 using DerTree_induction with (PL := fun l1 => forall l2, {l1=l2} + {l1<>l2}).
(* Clf *)
  destruct d2; [left; auto | right; discriminate | right ; discriminate].
(* Unf *)
  destruct d2; [ right; discriminate 
               | destruct (PropFSet_eq_dec x p); 
                  [ left; subst; auto 
                  | right; intuition; inversion H; auto]
               | right ; discriminate].
  destruct d2; [ right; discriminate 
               | right; discriminate 
               | ].
(* DerTree *)
  destruct (PropFSet_eq_dec x p) ; [ | right; intro NEQ; inversion NEQ; auto]. 
  destruct (Rule_eq_dec r r0); [ | right; intro NEQ; inversion NEQ; auto].
  destruct (IHd1 l0); [ | right; intro NEQ; inversion NEQ; auto]. 
  left; subst; trivial. 
(* No children *)
  destruct l2; auto. right. intro NEQ; inversion NEQ.
(* Some children *)
  destruct l2. right. intro NEQ; inversion NEQ.
  destruct (IHd1 d). subst. destruct (IHd0 l2).
  subst. left. trivial. right. intro NEQ. inversion NEQ. auto.
  right. intro NEQ; inversion NEQ; auto.
Defined.

Fixpoint instantiateAllPartitions (rule : Rule) (Γ : PropFSet) (π : list Partition) : list (list TableauNode) :=
  match π with
  | nil => nil
  | x::xs => let inst := applyPartition (getNumerator rule) x in
                        let X := removeMultSet inst Γ in
                        (tableauAppend X (denoApply x (getDenominator rule)))
                          :: instantiateAllPartitions rule Γ xs
  end
.

Compute instantiateAllPartitions AndRule ((¬(#"a" ∧ #"b"))::(#"a" ∧ #"b")::(#"c" ∧ #"d")::(#"s")::nil)
  (getPartitions (getNumerator AndRule) ((¬(#"a" ∧ #"b"))::(#"a" ∧ #"b")::(#"c" ∧ #"d")::(#"s")::nil)).

(*
Fixpoint applyRule' (rule : Rule) (T : TableauNode) : option (list TableauNode) :=
  match T with
  | inr res => Some ((inr res) :: nil)
  | inl Γ => match (getPartitions (getNumerator rule) Γ) with
             | nil => None
             | π::πs => let inst := applyPartition (getNumerator rule) π in
                        let X := removeMultSet inst Γ in
                        Some (tableauAppend X (denoApply π (getDenominator rule)))
             end
  end.
*)

Fixpoint applyRuleN (rule : Rule) (T : TableauNode) : list (list TableauNode) :=
  match T with
  | inr res => ((inr res) :: nil) :: nil
  | inl Γ => match (getPartitions (getNumerator rule) Γ) with
             | nil => nil
             | π => instantiateAllPartitions rule Γ π
             end
  end.

Print map.

Definition errorMap := fun (A B : Type) (f : list A -> B) =>
  fix errorMap (l : list (list A)) : list B :=
    match l with
    | nil => nil
    | a :: t => match a with
                | nil => errorMap t
                | _ => f a :: errorMap t
                end
    end.

(*
Fixpoint closeMap (l : list TableauNode) :=
  match l with
  | nil => nil
  | x::xs => match x with
             | inr Terminate => Clf :: closeMap xs
             | _ => Unf x :: closeMap xs
             end
  end.
*)
(*
Fixpoint applyRule (rule : Rule) (T : DerTree) : list DerTree :=
  match T with
  | Unf Γ => let llst := applyRuleN rule Γ in
              map (fun l => (Der Γ rule (closeMap l))) llst
  | Der Γ r derlist => let children := map (applyRule rule) derlist in
              errorMap _ _ (Der Γ r) children
  | Clf => Clf :: nil
  end.
*)

Inductive treeResult (A : Type) : Type :=
  | TerminateLeaf : treeResult A
  | Ok : A -> treeResult A
  | FailRes : treeResult A
  .

Fixpoint treeResBranch (A B : Type) (f : A -> treeResult B) (branches : list A) : treeResult B :=
  match branches with
  | nil => FailRes _
  | b::bs => match f b with
             | FailRes _ => FailRes _
             | TerminateLeaf _ => treeResBranch _ _ f bs
             | Ok _ res => Ok _ res
             end
  end.

Fixpoint derTreeCons (x : treeResult DerTree) (xs : treeResult (list DerTree)) :=
  match x with
  | FailRes _ => FailRes _
  | TerminateLeaf _ => match xs with
                    | FailRes _ => FailRes _
                    | TerminateLeaf _ => FailRes _
                    | Ok _ ress => Ok _ (Clf :: ress)
                    end
  | Ok _ res => match xs with
                    | FailRes _ => FailRes _
                    | TerminateLeaf _ => FailRes _
                    | Ok _ ress => Ok _ (res :: ress)
                    end
  end.

(*
Fixpoint derTreeResBind' (A : Type) (f : A -> treeResult DerTree) (branches : list A) (rule : Rule) (Γ : TableauNode) (acc : treeResult (list DerTree)) :=
  match branches with
  | nil => match acc with
           | Ok _ lst => match lst with
                         | nil => FailRes _
                         | _ => Ok _ (Der Γ rule lst)
                         end
           | _ => FailRes _
           end
  | b::bs => derTreeResBind' _ f bs rule Γ (derTreeCons (f b) acc)
  end.

Definition derTreeResBind (A : Type) (f : A -> treeResult DerTree) (branches : list A) rule Γ :=
  derTreeResBind' A f branches rule Γ (Ok _ nil).
*)

Fixpoint forBranchRes (A B : Type) (f : A -> treeResult B) (branches : list A) : treeResult B :=
  match branches with
  | nil => FailRes _
  | b::bs => match f b with
             | FailRes _ => forBranchRes _ _ f bs
             | res => res
             end
  end.

Fixpoint forBranch (A B : Type) (f : A -> option B) (branches : list A) : option B :=
  match branches with
  | nil => None
  | b::bs => match f b with
             | None => forBranch _ _ f bs
             | Some res => Some res
             end
  end.

Print DerTree.

(* Given a list of branches (of nodes), generates the parents of said nodes in DerTree *)
Fixpoint derTreeAppend (rule : Rule) (Γ : PropFSet) (branches : list TableauNode) (acc : list DerTree): option DerTree :=
  match branches with
  | nil => match acc with
           | nil => None
           | _ => Some (Der Γ rule acc)
           end
  | node::rest => match node with
                  | inr Terminate => derTreeAppend rule Γ rest (Clf :: acc)
                  | inl lst => derTreeAppend rule Γ rest (Unf lst :: acc)
                  end
  end.

Check derTreeAppend.
Print tableauAppend.
Print Denominator.

Definition applyPartitionRuleD (rule : Rule) (Γ : PropFSet) (π : Partition) :=
  let inst := applyPartition (getNumerator rule) π in
  let X := removeMultSet inst Γ in
  match π with
  | nil => None
  | _ => match (getDenominator rule) with
         | inr res => Some Clf
         | res => derTreeAppend rule Γ (tableauAppend X (denoApply π res)) nil
         end
  end.

Check applyPartitionRuleD.

Print DerTree.
Compute (applyPartitionRuleD AndRule (# "p"::nil) nil).
Compute (applyPartition (getNumerator IdRule) nil).
Compute (applyPartitionRuleD IdRule (# "p" :: ¬ # "p" :: nil) ((# "p", # "p")::nil)).

Check applyPartitionRuleD.

Print Denominator.
Print denoApply.
Print DerTree.
Print optionBind.

Definition optionCons (A : Type) (x : option A) (olst : option (list A)) :=
  match olst with
  | None => optionBind _ _ (fun a => Some (a::nil)) x
  | Some lst => match x with
         | None => olst
         | Some a => Some (a :: lst)
         end
  end.

Fixpoint optionSucMap' (A B : Type) (f : A -> option B) (xs : list A) (acc : option (list B)) :=
  match xs with
  | nil => acc
  | y::ys => optionSucMap' _ _ f ys (optionCons _ (f y) acc)
  end.

Definition optionSucMap (A B : Type) f xs := optionSucMap' A B f xs None.

(* Applies rule to a DerTree and gives a list of resulting derTrees. Only works on Leafs
   so that in the strat we apply a dft approach on the leaves such that this works *)
Fixpoint applyRuleD (rule : Rule) (T : DerTree) : option (list (DerTree)) :=
  match T with
  | Clf => Some (Clf :: nil)
  | Unf Γ => match (getPartitions (getNumerator rule) Γ) with
             | nil => None
             | Π => optionSucMap _ _ (applyPartitionRuleD rule Γ) Π
             end
  | Der Γ r lst => None
  end.

Compute (getPartitions (getNumerator IdRule) (¬ # "a" :: # "a" :: nil)).
Compute (applyRuleD IdRule (Unf (# "a" :: ¬ # "a" :: nil))).
Compute applyRuleD AndRule (Unf (((¬(#"a" ∧ #"b"))::(#"a" ∧ #"b")::(#"c" ∧ #"d")::(#"s")::nil))).

Print DerTree.
Print optionBind.

Inductive CRule := 
  | IdC : CRule
  | OrC : CRule
  | AndC : CRule.

Definition getCRule (cr : CRule) :=
  match cr with
  | IdC => IdRule
  | OrC => OrRule
  | AndC => AndRule
  end.

Inductive StrategyC :=
  | ApplyRule : CRule -> StrategyC
  | Sequence : StrategyC -> StrategyC -> StrategyC
  | Alternation : StrategyC -> StrategyC -> StrategyC
  | Skip : StrategyC
  | Fail : StrategyC
  | Repeat : StrategyC -> StrategyC
  .

Fixpoint stratLeftAlign (strat : StrategyC) : StrategyC :=
  match strat with
  | Sequence (Sequence s1 s2) s3 => Sequence s1 (Sequence s2 s3)
  | Alternation (Alternation s1 s2) s3 => Alternation s1 (Alternation s2 s3)
  | Sequence s1 s2 => Sequence (stratLeftAlign s1) (stratLeftAlign s2)
  | Alternation s1 s2 => Alternation (stratLeftAlign s1) (stratLeftAlign s2)
  | Repeat s => Repeat (stratLeftAlign s)
  | other => other
  end.

(*
Fixpoint connectivesProp (F : PropF) :=
  match F with
  | # pv => 0
  | ⊥ => 0
  | a ∧ b
  | a ∨ b
  | a → b => 1 + connectivesProp a + connectivesProp b
  end.

Fixpoint connectivesSet (Γ : PropFSet) :=
  match Γ with
  | nil => 0
  | x::xs => connectivesProp x + connectivesSet xs
  end.
*)
Fixpoint maxList (lst : list nat) :=
  match lst with
  | nil => 0
  | x::xs => max x (maxList xs)
  end.

(*
(* Define the relation as the maximum of leaves *)
Fixpoint countConnectivesDerTree (T : DerTree) :=
  match T with
  | Clf => 0
  | Unf Γ => connectivesSet Γ
  | Der _ _ branches => maxList (map countConnectivesDerTree branches)
  end.

Definition countOptionConnectivesDer (T : option DerTree) :=
  match T with
  | None => 0
  | Some res => countConnectivesDerTree res
  end.

Definition countFirstConnectives (Tlist : option (list DerTree)) :=
  match Tlist with
  | None => 0
  | Some res => match res with
                | nil => 0
                | x::_ => countConnectivesDerTree x
                end
  end.
*)

Print applyRuleD.

Fixpoint applyRuleDFirst (rule : Rule) (T : DerTree) :=
  match applyRuleD rule T with
  | Some (x::_) => Some x
  | _ => None
  end.

(*
Lemma cRelDec : forall (r : CRule) (T : DerTree),
  countOptionConnectivesDer (Some T) > countOptionConnectivesDer (applyRuleDFirst (getCRule r) T).
Proof.
  (*
  intros. induction T; induction r; simpl in *.
    case (getPartitions (# "p" :: ¬ # "p" :: nil) p).
    simpl. apply connectivesSetNonZero.
    intros.
     unfold optionSucMap. simpl.
    case p0; simpl. 
    case (optionSucMap' Partition DerTree
      (applyPartitionRuleD
         (# "p" :: ¬ # "p" :: nil, inr Terminate) p) l).
    intros. induction l0; simpl; intuition.

    Check applyPartitionRuleD.
    Print applyPartitionRuleD.
    Print optionSucMap.
  *)
  Admitted.
Print DerTree.
Print optionCons.
*)

Fixpoint optionMap (A B : Type) (f : A -> option B) (lstA : list A) :=
  match lstA with
  | nil => Some nil
  | x::xs => match f x with
          | None => None
          | res => optionCons _ res (optionMap _ _ f xs)
          end
  end.

Fixpoint optionDerConstruct (f : DerTree -> option DerTree) (Γ : PropFSet) (rule : Rule) (branches : list DerTree) :=
  match branches with
  | nil => None
  | lst => match (optionMap _ _ f lst) with
           | None => None
           | Some res => Some (Der Γ rule res)
           end
  end.

Lemma maxAdd : forall n m, n + m <= 2 * max n m.
Proof.
  intros.
  pose (h1 := le_max_l n m).
  pose (h2 := le_max_r n m).
  intuition.
Qed.

Check well_founded.

(*
Lemma connectivesProp_wf : well_founded (fun (p : PropF) q => connectivesProp p < connectivesProp q).
unfold well_founded.
induction a;
constructor; intros. try (simpl in *; induction y; simpl; try omega).
try (simpl in *; induction y; simpl; try omega).
simpl in *.
assert ((connectivesProp a1 + connectivesProp a2) <= (2 * max (connectivesProp a1) (connectivesProp a2)))
by apply maxAdd.
assert (connectivesProp y <= S ( 2 * Nat.max (connectivesProp a1) (connectivesProp a2))) by omega.
destruct IHa1.

(*
destruct (eq_nat_dec (connectivesProp y) (2 * max (connectivesProp a1) (connectivesProp a2))).
constructor. intros.
destruct (max_dec (connectivesProp a1) (connectivesProp a2)).
rewrite e0 in e.
apply IHa1. rewrite e in H2. exact H0.
rewrite e0 in e.
apply IHa2. rewrite e in H0. exact H0.
simpl in *.
apply IHa1. *)
Admitted.*)

(*
Lemma connectivesSet_wf : well_founded (fun (Γ : PropFSet) Δ => connectivesSet Γ < connectivesSet Δ).
unfold well_founded. induction a.
constructor. intros. simpl in H. omega.
constructor. intros.
destruct (eq_nat_dec (connectivesSet y) (connectivesSet a0)).
constructor; intros. apply IHa. rewrite e in H0. exact H0.
apply IHa. simpl in *.
induction a; simpl in *; try (assumption).
Admitted.
*)

Definition inputTest := prod DerTree StrategyC.

Fixpoint mapTest (strat : StrategyC) (lstT : list DerTree) :=
  match lstT with
  | nil => nil
  | x::xs => (x, strat) :: mapTest strat xs
  end.

Definition constructorODer (Γ : PropFSet) (rule : Rule) (olst : option (list DerTree)) :=
  match olst with
  | None => None
  | Some res => Some (Der Γ rule res)
  end.

Print applyRuleDFirst.
Print CRule.
(*Lemma applyRuleArgLeaves : forall T x r, applyRuleDFirst r T = Some x
  -> (exists y, T = Unf y) \/ T = Clf.
Proof.
  intros.
  induction T.
  refine (or_introl _).
  refine (ex_intro _ p _ ). trivial.
  assert (applyRuleDFirst r (Der p r0 l) = None).
  unfold applyRuleDFirst.
  induction r0, r. simpl in *.
  discriminate.
  rewrite H in H0. discriminate.
  simpl in *.
  refine (or_intror _). trivial.
Qed.*)

Lemma AndCRuleArg : forall T x, applyRuleDFirst (getCRule AndC) T = Some x
  -> (exists y a b, T = Unf y -> In (a ∧ b) y) \/ T = Clf.
  Admitted.

(*
Definition applyStratNBleaf (T : DerTree) : StrategyC -> option DerTree.
  refine ((Fix rel_wf) (fun _ => StrategyC -> option DerTree)
  (fun T applyStratNBleaf_rec =>
  (match T as T' return (T=T' -> StrategyC -> option DerTree) with
  | Unf _ => fun H strat => (
             match strat with
             | Skip => Some T
             | Fail => None
             | ApplyRule r => applyRuleDFirst (getCRule r) T
             | Sequence s1 s2 => match applyStratNBleaf_rec T _ s1 with
                                 | None => None
                                 | Some Clf => Some Clf
                                 | Some (Der Γ r branches) => constructorODer Γ r (optionMap _ _ (fun i => applyStratNBleaf_rec i _ s1) branches)
                                 
                                 | _ => None
                                 end
             | Alternation s1 s2 => match applyStratNBleaf_rec T _ s1 with
                                    | None => applyStratNBleaf_rec T _ s2
                                    | res => res
                                    end
             | Repeat s => match applyStratNBleaf_rec T _ s with
                           | Some (Der Γ r branches) => constructorODer Γ r (optionMap _ _ (fun i => applyStratNBleaf_rec i _ (Repeat s)) branches)
                           | _ => Some T
                           end
             (*| _ => None*)
    end)
  | _ => fun _ _ => None
  end) eq_refl) T).
  rewrite H. simpl.
  admit.
  rewrite H. simpl. admit. admit. admit. admit.
Admitted.
*)

Fixpoint applyStratNBleaf_norepeat (strat : StrategyC) (T : DerTree) :=
  match T with
  | Unf _ => match strat with
             | Skip => Some T
             | Fail => None
             | ApplyRule r => applyRuleDFirst (getCRule r) T
             | Sequence s1 s2 => match applyStratNBleaf_norepeat s1 T with
                                 | None => None
                                 | Some Clf => Some Clf
                                 | Some (Der Γ r branches) => 
                                 
                                 optionDerConstruct (applyStratNBleaf_norepeat s2) Γ r branches
                                 | _ => None
                                 end
             | Alternation s1 s2 => match applyStratNBleaf_norepeat s1 T with
                                    | None => applyStratNBleaf_norepeat s2 T
                                    | res => res
                                    end
             | _ => None
    end
  | _ => None
  end.

Print getPartitions.

Inductive CRulePos :=
  | fchoice : CRule -> list DerTree -> CRulePos.

Inductive nextStep :=
  | rchoice : DerTree -> list (CRulePos) -> nextStep.

Print applyRuleN.
Print CRule.

Definition CRules := IdC::AndC::OrC::nil.

Fixpoint getGoals (T : DerTree) : list DerTree :=
  match T with
  | Der _ _ branches => match branches with
                        | nil => nil
                        | _ => flat_map getGoals branches
                        end
  | Clf => nil
  | Unf _ => T :: nil
  end.

(*
Fixpoint traverseToNG_help (Ts : list DerTree) (n : nat) (acc : list DerTree) :=
  match Ts with
  | nil => None
  | x::xs => 
                (let xchild := (length (getGoals x)) in
                 if le_dec xchild n then Some (acc, x, xs, n) else traverseToNG_help xs (minus n xchild) (x::acc))
  end. *)

Compute (getGoals (Der nil (getCRule AndC) (Clf::(Unf (⊥::nil))::nil))).
Compute (getGoals (Der (# "a" ∧ # "b" :: # "a" ∧ # "a" :: nil)
            (# "p" ∧ # "q" :: nil,
            inl ((# "p" :: # "q" :: nil) :: nil))
            (Unf ((#"a" ∧ #"b")::nil) :: Unf ((⊥ ∧ ⊥)::nil) ::nil))).

Fixpoint traverseToNG_help (Ts : list DerTree) (n : nat) (acc : list DerTree) :=
  if gt_dec n (length Ts) then None else (
  if eq_nat_dec n 0 then None else (
  match Ts with
  | nil => None
  | x::xs => match x with
             | Clf => traverseToNG_help xs n (acc ++ (x::nil))
             | _ => let xchild := (length (getGoals x)) in
                    if le_dec n xchild then Some (acc, x, xs, n)
                    else traverseToNG_help xs (minus n xchild) (acc ++ (x::nil))
             end
  end)).

Check traverseToNG_help.

Definition traverseToNG (Ts : list DerTree) (n : nat) := traverseToNG_help Ts n nil.

Compute (traverseToNG_help (Clf::(Unf (⊥::nil))::nil) 0 nil).
Compute (traverseToNG_help (
            (Unf ((#"a" ∧ #"b")::nil) :: Unf ((⊥ ∧ ⊥)::nil) ::nil)) 2 nil).
Print DerTree.
Print maxList.
Print map.

Fixpoint depthDerTree (T : DerTree) :=
  match T with
  | Unf _ => 0
  | Der _ _ branch => 1 + maxList (map depthDerTree branch)
  | Clf => 0
  end.

Definition depthOrder T1 T2 := depthDerTree T1 < depthDerTree T2.

Print DerTree.
Print DerTree_ind.
Print DerTree_rect.

Fixpoint sumList (list : list nat) :=
  match list with
  | nil => 0
  | x::xs => x + sumList xs
  end.

Fixpoint sizeDerTree (T : DerTree) :=
  match T with
  | Unf _ => 0
  | Der _ _ branch => 1 + sumList (map sizeDerTree branch)
  | Clf => 0
  end.

Inductive tail_of (A : Type) : list A -> list A -> Prop :=
  | nil_tail : forall (x : A) (xs : list A), tail_of A (x::xs) nil
  | current_tail : forall x xs ys, xs = ys -> tail_of A (x::xs) ys
  | next_tail : forall x xs ys, tail_of A xs ys -> tail_of A (x::xs) ys.
  
Implicit Arguments tail_of [A].

Lemma complete_list_ind (A : Type) (f : forall (x y : A), {x=y} + {x<>y}) (P : list A -> Prop) :
 (forall  l : list A, (forall l2 : list A, tail_of l l2 -> P l2) -> P l) ->
 forall (l : list A), P l.
 intros. apply H. induction l.
 intros. inversion H0.
 intros. destruct (list_eq_dec f l l2).
 apply H. intros. apply IHl. rewrite e. exact H1.
 inversion H0; auto; subst. apply H. intros. inversion H1.
 contradict n. trivial.
 Defined.

Print depthOrder.

Definition maxListDepthOrder (l1 l2 : list DerTree) := maxList (map depthDerTree l1) < maxList (map depthDerTree l2).
Definition maxDepthOrder (t1 t2 : DerTree) := maxListDepthOrder (t1 :: nil) (t2 :: nil).

Print maxList.

Lemma maxListElement : forall l n, l <> nil -> maxList l = n -> In n l.
Proof.
  intros.
  destruct (eq_nat_dec 0 n).
  rewrite <- e. induction l.
  contradict H; auto.
  assert (a = 0).
  rewrite <- e in *.
  simpl in H0.
  destruct (max_dec a (maxList l)).
  omega.
  pose (le_max_l a (maxList l)). omega.
  simpl. left; trivial.
  induction l.
  contradict H; auto.
  simpl.
  simpl in H0.
  destruct (max_dec a (maxList l)).
  left; omega.
  right. apply IHl.
  intuition. rewrite e in H0. rewrite H1 in H0.
  simpl in H0. auto.
  omega.
Qed.

Lemma depthOrder_wf : well_founded depthOrder.
  unfold well_founded.
  induction a using DerTree_induction with (PL := fun branch => forall b, depthDerTree b < S (maxList (map depthDerTree branch)) -> Acc depthOrder b).
  constructor; intros; red in H; red in H; simpl in H; omega.
  constructor; intros; red in H; red in H; simpl in H; omega.
  constructor. intros.
  red in H. simpl in H.
  exact (IHa y H).

  intros. simpl in H. induction b.
  constructor; intros; red in H0; red in H0; simpl in H0; omega.
  constructor; intros; red in H0; red in H0; simpl in H0; omega.
  simpl in H; contradict H; omega.
  intros. simpl in H.
  destruct (max_dec (depthDerTree a) (maxList (map depthDerTree xs)));
  rewrite e in H.
  destruct (eq_nat_dec (depthDerTree b) (depthDerTree a)).
  constructor. intros.
  apply IHa. red in H0. rewrite e0 in H0.
  red; exact H0.
  assert ((depthDerTree b) < (depthDerTree a)) by omega.
  apply IHa. red; exact H0.
  exact (IHa0 b H).
Defined.

Print depthOrder.
Print traverseToNG_help.

Definition toBranchNGfix (Ts : list DerTree) (n : nat) (acc : list DerTree) :=
  match Ts with
  | nil => None
  | res => traverseToNG_help res n acc
  end.

Check Fix_eq.
(*Fix_Eq*)


Lemma toBranchZero : forall branches acc, traverseToNG_help branches 0 acc = None.
Proof.
  induction branches.
  intuition.
  simpl. intros. trivial.
Qed.

Lemma branch_contains : forall branches x acc xs n n' foo, traverseToNG_help branches n foo = Some (acc, x, xs, n') -> In x branches.
Proof.
  induction branches. intros. inversion H.
  induction n; simpl in H1; discriminate H1.
  intros. inversion H.
  destruct (gt_dec n (S (length branches))).
  discriminate H1.
  simpl.
  destruct a;
  destruct (eq_nat_dec n 0); try discriminate H1.
  right. apply (IHbranches x acc xs n n' (foo ++ Clf :: nil)). auto.
  simpl in H1. destruct (le_dec n 1).
  inversion H1. left. trivial.
  right.
  apply (IHbranches x acc xs (n - 1) n' (foo ++ (Unf p) :: nil)). auto.
  destruct (le_dec n (length (getGoals (Der p r l)))).
  inversion H1; left; trivial.
  right.
  apply (IHbranches x acc xs (n - length (getGoals (Der p r l))) n' (foo ++ Der p r l :: nil)). auto.
Qed.

(*
Lemma branch_contains : forall branches x acc xs n n' foo, traverseToNG_help branches n foo = Some (acc, x, xs, n') -> In x branches.
Proof.
  induction branches. intros. inversion H.
  intros.
  simpl in H.
  destruct (le_dec (length (getGoals a)) n).
  inversion H; simpl; auto.
  simpl. right.
  apply (IHbranches x acc xs (n - length (getGoals a)) n' (a :: foo)).
  auto.
Qed.
*)

Lemma maxAssoc : forall x y z, max x (max y z) = max (max x y) z.
Proof.
  intros.
  destruct (le_ge_dec x y) as [a|a];
  destruct (le_ge_dec y z) as [b|b];
  destruct (le_ge_dec x z) as [c|c];
  ((pose (Ha := max_r _ _ a); rewrite Ha) || (pose (Ha := max_l _ _ a); rewrite Ha));
  ((pose (Hb := max_r _ _ b); rewrite Hb) || (pose (Hb := max_l _ _ b); rewrite Hb));
  ((pose (Hc := max_r _ _ c); rewrite Hc) || (pose (Hc := max_l _ _ c); try rewrite Hc));
  repeat (rewrite Ha || rewrite Hb || rewrite Hc); omega.
Qed.

Lemma maxListApp : forall xs ys, maxList (xs ++ ys) = max (maxList xs) (maxList ys).
Proof.
  intros. induction xs.
  simpl. trivial.
  intros. simpl. rewrite IHxs.
  exact (maxAssoc _ _ _).
Qed.

Lemma childLDepth : forall branches Γ r,
  (forall b, In b branches -> depthOrder b (Der Γ r branches)).
Proof.
  intros. destruct (in_split _ _ H). destruct H0.
  subst. unfold depthOrder. simpl.
  assert (map depthDerTree (x ++ b :: x0) = (map depthDerTree x) ++ (map depthDerTree (b::x0))) by exact (map_app _ _ _).
  simpl in H0. rewrite H0.
  assert (maxList (map depthDerTree x ++ depthDerTree b :: map depthDerTree x0) =
  max (maxList (map depthDerTree x)) (maxList (depthDerTree b :: map depthDerTree x0))) by exact (maxListApp _ _).
  rewrite H1. simpl.
  destruct (le_ge_dec (depthDerTree b) (maxList (map depthDerTree x0))) as [am|am];
  destruct (le_ge_dec (maxList (map depthDerTree x))
     (Nat.max (depthDerTree b) (maxList (map depthDerTree x0)))) as [bm|bm];
  ((pose (Ha := max_l _ _ am); rewrite Ha) || (pose (Ha := max_r _ _ am); try rewrite Ha));
  ((pose (Hb := max_l _ _ bm); rewrite Hb) || (pose (Hb := max_r _ _ bm); try rewrite Hb));
  rewrite Ha in Hb;
  try rewrite Ha; try rewrite Hb; try auto; try omega.
  rewrite (max_comm _ _). rewrite Hb.
  omega.
  rewrite (max_comm _ _). rewrite Hb. omega.
Qed.


Definition testBranch (T : DerTree) : (DerTree -> DerTree) -> DerTree.
  refine (Fix depthOrder_wf (fun _ => (DerTree -> DerTree) -> DerTree)
  (fun T testBranch_rec  =>
  (match T as T' return (T = T' -> (DerTree -> DerTree) -> DerTree) with
  | Der Γ r (x::xs) => (fun _ f => testBranch_rec x _ f)
  | _ => (fun _ f => f T)
  end) eq_refl) T).
  subst.
  red; simpl.
  destruct (max_dec (depthDerTree x) (maxList (map depthDerTree xs))).
  rewrite e. omega.
  pose (le_max_l (depthDerTree x) (maxList (map depthDerTree xs))).
  rewrite e in *. omega.
  Defined.

Compute (testBranch Clf (fun _ => Clf)).

(* Might want to change it to an option type *)
Definition toBranchNG (T : DerTree) : (DerTree -> DerTree) -> nat -> DerTree.
  refine (Fix depthOrder_wf (fun _ => (DerTree -> DerTree) -> nat -> DerTree)
  (fun T toBranchNG_rec  =>
  (match T as T' return (T = T' -> (DerTree -> DerTree) -> nat -> DerTree) with
  | Der Γ r branches => (fun _ f n => (match traverseToNG branches n as cinfo
                        return (((traverseToNG branches n) = cinfo) -> DerTree) with
                        | Some (acc, x, xs, n') => (fun H => Der Γ r (acc ++ (toBranchNG_rec x _ f n') :: xs))
                        | None => fun _ => T
                        end) eq_refl)
  | _ => (fun _ f n => f T)
  end) eq_refl) T).
  subst.
  assert (In x branches).
  exact (branch_contains branches x acc xs n n' nil H).
  pose (childLDepth branches Γ r).
  exact (d x H0).
  Defined.

Compute (toBranchNG Clf (fun _ => Clf) 1).

Print getPartitions.
Print applyRuleD.

Definition getNGoal (T : DerTree) : nat -> option DerTree.
  refine (Fix depthOrder_wf (fun _ => (nat -> option DerTree))
  (fun T getNGoal_rec =>
  (match T as T' return (T=T' -> nat -> option DerTree) with
  | Der _ _ branches => fun H n => (
                        (match traverseToNG branches n as branchRes
                        return (traverseToNG branches n = branchRes -> option DerTree) with
                        | None => fun _ => None
                        | Some (_, x, _, n') => fun _ => getNGoal_rec x _ n'
                        end) eq_refl)
  | _ => fun _ n => if eq_nat_dec n 0 then None else Some T
  end) eq_refl) T).
    subst.
  assert (In x branches).
  exact (branch_contains branches x l0 l n n' nil e).
  pose (childLDepth branches p r).
  exact (d x H).
  Defined.

Check getNGoal.
Compute (getNGoal (Unf (⊥::nil)) 1).

Print getPartitions.
Print getCRule.
Print applyRuleN.
Print instantiateAllPartitions.
Print applyPartitionRuleD.
Print optionSucMap.

Definition updateLeaf (T : DerTree) : (DerTree -> DerTree) := fun _ => T.

Definition applyRtoNG (T : DerTree) (rule : Rule) (n : nat) :=
  match getNGoal T n with
  | None => None
  | Some goal => 
      match goal with
      | Unf Γ => match getPartitions (getNumerator rule) Γ with
                 | nil => None
                 | Π => match optionSucMap _ _ (applyPartitionRuleD rule Γ) Π with
                        | None => None
                        | Some newNodes =>
                        Some (map (fun x => toBranchNG T x n) (map updateLeaf newNodes))
                        end
                 end
      | _ => None
      end
  end.

Definition applyCRtoNG (T : DerTree) (rule : CRule) (n : nat) := applyRtoNG T (getCRule rule) n. 

Recursive Extraction applyRtoNG.

Fixpoint pickNFApply (results : option (list DerTree)) (n : nat) :=
  match results with
  | None => None
  | Some nil => None
  | Some (x::xs) => match n with
                    | 0 => None
                    | 1 => Some x
                    | S n' => pickNFApply (Some xs) n'
                    end
  end.

Fixpoint pickNFApply_nil (results : option (list DerTree)) (n : nat) :=
  match results with
  | None => Unf nil
  | Some nil => Unf nil
  | Some (x::xs) => match n with
                    | 0 => Unf nil
                    | 1 => x
                    | S n' => pickNFApply_nil (Some xs) n'
                    end
  end.

Compute applyCRtoNG (Unf ((#"a" ∧ #"b")::(#"a" ∧ #"a")::nil)) AndC 1.
Compute applyCRtoNG (Der (# "a" ∧ # "b" :: # "a" ∧ # "a" :: nil)
            (# "p" ∧ # "q" :: nil,
            inl ((# "p" :: # "q" :: nil) :: nil))
            (Unf ((#"a" ∧ #"b")::nil) :: Unf ((⊥ ∧ ⊥)::nil) ::nil)) AndC 2.

Definition cpl_example := (#"A" ∧ ((¬ (#"A")) ∨ (# "B")) ∧ (¬ (# "B"))).

Definition step1 := Unf (cpl_example :: nil).
Definition step2 := pickNFApply_nil (applyCRtoNG step1 AndC 1) 1.
Definition step3 := pickNFApply_nil (applyCRtoNG step2 AndC 1) 1.
Definition step4 := pickNFApply_nil (applyCRtoNG step3 OrC 1) 1.
Definition step5 := pickNFApply_nil (applyCRtoNG step4 IdC 1) 1.
Definition step6 := pickNFApply_nil (applyCRtoNG step5 IdC 1) 1.

Compute getGoals step1.
Compute getGoals step2.
Compute getGoals step3.
Compute getGoals step4.
Compute getGoals step5.
Compute getGoals step6.

(*
Fixpoint applyStratNB' (strat : StrategyC) (T : DerTree) :=
  match T with
  | Clf => Some Clf
  | Der Γ r branches => optionDerConstruct (applyStratNB' strat) Γ r branches
  | leaf => 
    match strat with
    | Skip => Some T
    | Fail => None
    | ApplyRule r => applyRuleDFirst (getCRule r) T
    | Sequence s1 s2 => optionBind _ _ (applyStratNB' s2) (applyStratNB' s1 T)
    | Alternation s1 s2 => match applyStratNB' s1 T with
                           | None => applyStratNB' s2 T
                           | res => res
                           end
    (*| Repeat s => applyStratNB' (Sequence (Alternation s Skip) (Repeat s)) T*)
    | _ => None
    end
  end.

Fixpoint applyRule (rule : Rule) (T : DerTree) : list (treeResult DerTree) :=
  match T with
  | Unf Γ => match applyRuleN rule Γ with
             | nil => nil
             | llst => 
             Ok _ (map (fun l => (Der Γ rule (closeMap l))) llst)
             end
  | Der Γ r derlist => match derlist with
                       | nil => FailRes _
                       | b::bs => match b with
                                  | TerminateLeaf _ 
  | Clf => (TerminateLeaf _) :: nil
  end.

Fixpoint applyRules' (rule : Rule) (T : DerTree) : list (treeResult DerTree) :=
  match T with
  | Clf => Clf
  | Unf node => match applyRuleN rule Γ with
                | nil => FailRes _
                | 

Fixpoint applyStrat' (strat : Strategy) (T : DerTree) : treeResult DerTree :=
  match T with
  | Unf node => match strat with
                | Skip => Ok _ (Unf node)
                | Fail => FailRes _
                | ApplyRule r => match applyRule Γ r with
                                 | nil => FailRes _
                                 | r::res => Ok _ r
                                 end
                | Sequence s1 s2 => match s1 with
                                    | ApplyRules r => forBranchRes _ _ (applyStrat' s1) 
                                    | _ => 
                end
  | Der node rule children =>
  | Clf => Clf
*)
(*
Fixpoint applyRule (rule : Rule) (T : DerTree) : treeResult (list DerTree) :=
  match T with
  | Unf Γ => match applyRuleN rule Γ with
             | nil => FailRes _
             | llst => Ok _ (map (fun l => (Der Γ rule (closeMap l))) llst)
             end
  | Der Γ r derlist => match derlist with
                       | nil => FailRes _
                       | lst => treeResBranch _ _ (applyRule rule) lst
                       end
  | Clf => TerminateLeaf _
  end.

Fixpoint applyRule (rule : Rule) (T : DerTree) : option (list DerTree) :=
  match T with
  | Unf Γ => let llst := applyRuleN rule Γ in
              Some (map (fun l => (Der Γ rule (closeMap l))) llst)
  | Der Γ r derlist => let children := map (applyRule rule) derlist in
              errorMap _ _ (Der Γ r) children
  | Clf => Some (Clf :: nil)
  end.

Compute applyRule AndRule (Unf (inl ((¬(#"a" ∧ #"b"))::(#"a" ∧ #"b")::(#"c" ∧ #"d")::(#"s")::nil))).
Compute applyRule AndRule (Der
         (inl
            (# "a" ∧ # "b" → ⊥
             :: # "a" ∧ # "b"
                :: # "c" ∧ # "d" :: # "s" :: nil))
         (# "p" ∧ # "q" :: nil,
         inl ((# "p" :: # "q" :: nil) :: nil))
         (Unf
            (inl
               (# "a"
                :: # "b"
                   :: # "a" ∧ # "b" → ⊥
                      :: # "c" ∧ # "d" :: # "s" :: nil))
          :: nil)).
(* Should return nil as no leaf can be used with or rule *)
Compute applyRule OrRule (Der
         (inl
            (# "a" ∧ # "b" → ⊥
             :: # "a" ∧ # "b"
                :: # "c" ∧ # "d" :: # "s" :: nil))
         (# "p" ∧ # "q" :: nil,
         inl ((# "p" :: # "q" :: nil) :: nil))
         (Unf
            (inl
               (# "a"
                :: # "b"
                   :: # "a" ∧ # "b" → ⊥
                      :: # "c" ∧ # "d" :: # "s" :: nil))
          :: nil)).
Compute applyRule OrRule (Unf (inl ((¬(#"a" ∧ #"b"))::(#"a" ∧ #"b")::(#"c" ∧ #"d")::(#"s")::nil))).
Compute applyRule OrRule (Unf (inl ((¬(#"a" ∧ #"b"))::(#"a" ∨ #"b")::(#"c" ∧ #"d")::(#"s")::nil))).
Compute applyRule AndRule (Der
         (inl
            (# "a" ∧ # "b" → ⊥
             :: # "a" ∨ # "b"
                :: # "c" ∧ # "d" :: # "s" :: nil))
         (# "p" ∨ # "q" :: nil,
         inl ((# "p" :: nil) :: (# "q" :: nil) :: nil))
         (Unf
            (inl
               (# "a"
                :: # "a" ∧ # "b" → ⊥
                   :: # "c" ∧ # "d" :: # "s" :: nil))
          :: Unf
               (inl
                  (# "b"
                   :: # "a" ∧ # "b" → ⊥
                      :: # "c" ∧ # "d" :: # "s" :: nil))
             :: nil)).
*)
(*
Definition addHistory := fun (steps : list DerTree) :=
  fix addHistory (branches : list DerTree) :=
  match branches with
  | nil => nil
  | x::xs => match x with
             | nil => addHistory xs
             | _ => (x :: steps
*)

(* History is currently being displayed as a list of lists of (DerTree, Strategy) Tuples *)
(*
Definition historyStack := list (list (prod DerTree Strategy)).

Fixpoint popHistory (history : historyStack) : option (prod (prod DerTree Strategy) historyStack) :=
  match history with
  | nil => None
  | level::rst => match level with
                  | nil => popHistory rst
                  | x::xs => Some (x, (xs::rst))
                  end
  end.

Definition pushHistory entry (history : historyStack) := entry :: history.

Definition stackPair := prod DerTree historyStack.

Fixpoint applyStrategy' (strat : Strategy) (pair : stackPair) : option DerTree :=
  let (Γ, history) := pair in
  match strat with
  | Skip => Some Γ
  | Fail => match popHistory history with
            | None => None
            | Some ((Γ', strat'), history') => applyStrategy' strat' (Γ', history')
            end
  | _ => None
  end.
  | ApplyRule r => let next := applyRule r Γ in
                   match next with
                   | nil => match popHistory history with
                            | None => nil
                   | x::xs => applyRule 
                   end
  | Sequence s1 s2 => let next1 := applyStrategy' s1 Γ in optionBind _ _ (applyStrategy' s2) next1
  | _ => None
  end.
*)

Fixpoint applyStrategy' (strat : Strategy) (Γ : DerTree) : option DerTree :=
  match strat with
  | Skip => Some Γ
  | Fail => None
  | ApplyRule r => match applyRule r Γ with
                   | nil => None
                   | x::_ => Some x
                   end
  | Sequence s1 s2 => match s1 with
                      | ApplyRule r => forBranch _ _ (applyStrategy' s2) (applyRule r Γ)
                      | other => optionBind _ _ (applyStrategy' s2) (applyStrategy' s1 Γ)
                      end
  | Alternation s1 s2 => match applyStrategy' s1 Γ with
                         | None => applyStrategy' s2 Γ
                         | Some res => Some res
                         end
  | _ => None
  end.
 

Definition applyStrategy (strat : Strategy) (Γ : PropFSet) : option DerTree :=
  applyStrategy' (stratLeftAlign strat) (Unf (inl Γ)).

Compute applyStrategy (ApplyRule AndRule) ((¬(#"a" ∧ #"b"))::(#"a" ∧ #"b")::(#"c" ∧ #"d")::(#"s")::nil).
Compute applyStrategy (Sequence (ApplyRule AndRule) (ApplyRule AndRule)) ((¬(#"a" ∧ #"b"))::(#"a" ∧ #"b")::(#"c" ∧ #"d")::(#"s")::nil).

Definition SystematicTableau 

Recursive Extraction applyRule.