(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)




type key = Ident.t

let compare_key (x : Ident.t) (y : Ident.t) =
    (* Can not overflow *)
    let u = x.stamp - y.stamp in
    if u = 0 then 
      let u = String.compare x.name y.name in 
      if u = 0 then 
        x.flags - y.flags 
      else  u 
    else u 
type 'a t = (key, 'a) Bal_map_common.t 
open Bal_map_common 

let empty = Bal_map_common.empty 
let is_empty = Bal_map_common.is_empty
let iter = Bal_map_common.iter
let fold = Bal_map_common.fold
let for_all = Bal_map_common.for_all 
let exists = Bal_map_common.exists 
let singleton = Bal_map_common.singleton 
let cardinal = Bal_map_common.cardinal
let bindings = Bal_map_common.bindings
let choose = Bal_map_common.choose 
let partition = Bal_map_common.partition 
let filter = Bal_map_common.filter 
let map = Bal_map_common.map 
let mapi = Bal_map_common.mapi

let bal = Bal_map_common.bal 
let height = Bal_map_common.height 
let join = Bal_map_common.join 
let concat_or_join = Bal_map_common.concat_or_join 

let rec add x data (tree : _ t) : _ t =
  match tree with 
  | Empty ->
    Node(Empty, x, data, Empty, 1)
  | Node(l, v, d, r, h) ->
    let c = compare_key x v in
    if c = 0 then
      Node(l, x, data, r, h)
    else if c < 0 then
      bal (add x data l) v d r
    else
      bal l v d (add x data r)

let rec find x (tree : _ t) =
  match tree with 
  | Empty ->
    raise Not_found
  | Node(l, v, d, r, _) ->
    let c = compare_key x v in
    if c = 0 then d
    else find x (if c < 0 then l else r)

let rec mem x  (tree : _ t) =
  match tree with 
  | Empty ->
    false
  | Node(l, v, d, r, _) ->
    let c = compare_key x v in
    c = 0 || mem x (if c < 0 then l else r)

let rec split x (tree : _ t) : _ t * _ option * _ t  =
  match tree with 
  | Empty ->
    (Empty, None, Empty)
  | Node(l, v, d, r, _) ->
    let c = compare_key x v in
    if c = 0 then (l, Some d, r)
    else if c < 0 then
      let (ll, pres, rl) = split x l in (ll, pres, join rl v d r)
    else
      let (lr, pres, rr) = split x r in (join l v d lr, pres, rr)

let rec merge f (s1 : _ t) (s2 : _ t) : _ t =
  match (s1, s2) with
  | (Empty, Empty) -> Empty
  | (Node (l1, v1, d1, r1, h1), _) when h1 >= height s2 ->
    let (l2, d2, r2) = split v1 s2 in
    concat_or_join (merge f l1 l2) v1 (f v1 (Some d1) d2) (merge f r1 r2)
  | (_, Node (l2, v2, d2, r2, h2)) ->
    let (l1, d1, r1) = split v2 s1 in
    concat_or_join (merge f l1 l2) v2 (f v2 d1 (Some d2)) (merge f r1 r2)
  | _ ->
    assert false

let of_list lst = 
  List.fold_left (fun acc (k,v) -> add k v acc) empty lst

let keys map = fold (fun k _ acc -> k::acc  ) map []

(* TODO: have this in stdlib/map to save some time *)
let add_if_not_exist key v m = 
  if mem key m then m else add key v m

let merge_disjoint m1 m2 = 
  merge 
    (fun k x0 y0 -> 
       match x0, y0 with 
         None, None -> None
       | None, Some v | Some v, None -> Some v
       | _, _ -> invalid_arg "merge_disjoint: maps are not disjoint")
    m1 m2
