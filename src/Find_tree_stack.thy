theory Find_tree_stack
imports Util Constants Tree Insert_tree_stack Key_value
begin

(* tr: we return a pair of a focus and the context; the focus is just
   the tree at the position; at the end of Find, this is
   guaranteed to be a leaf; also include the key we are looking
   for; also include bounds on the keys that we may find
*)
datatype fts_state = Fts_state "key * Tree * context_t"

definition dest_fts_state :: "fts_state => (key * Tree * context_t)" where
"dest_fts_state fts == (case fts of Fts_state (k,t,c) => (k,t,c))"
 
definition tree_to_fts :: "key => Tree => fts_state" where
"tree_to_fts k t == (
Fts_state (k,t,Nil))"

(* tr: link between focus and context?*)
definition wellformed_fts_focus :: "rmbs_t => Tree => bool" where
"wellformed_fts_focus rmbs t == (
wellformed_tree rmbs t)"

definition wellformed_fts_1 :: "fts_state => bool" where
"wellformed_fts_1 fts == (
let (k,t,ctx) = dest_fts_state fts in
(case ctx of
Nil => True
| x#xs =>
 let (lb,((ks,rs),i),rb) = x in
 (t = rs!i)
 (*tr: the keys of the focus are bounded by constraints on context*)
))"

definition wellformed_fts :: "fts_state => bool" where
"wellformed_fts fts == (
let (k,t,ctx) = dest_fts_state fts in
let rmbs = Rmbs(ctx = Nil) in
wellformed_fts_focus rmbs t
& wellformed_context ctx
& wellformed_fts_1 fts)"

(*tr: stops when gets to leaf; no "errors"*)
definition step_fts :: "fts_state => fts_state option" where
"step_fts fts == (
let (k,t,ctx) = dest_fts_state fts in
let (lb,rb) =
 case ctx of Nil => (None,None)
 | (lb,_,rb)#_ => (lb, rb) 
in
(case t of
Leaf _ => None
| Node(ks,rs) =>
 let i = search_key_to_index ks k in
 let (l,u) = get_lower_upper_keys_for_node_t ks lb i rb in
 let ctx2 = (l,((ks,rs),i),u)#ctx in
 Some(Fts_state(k,t,ctx2))
))"
end