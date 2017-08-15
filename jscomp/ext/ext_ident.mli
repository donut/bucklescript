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








(** A wrapper around [Ident] module in compiler-libs*)

 val is_js : Ident.t -> bool 

val is_js_object : Ident.t -> bool

(** create identifiers for predefined [js] global variables *)
val create_js : string -> Ident.t

val create : string -> Ident.t

 val make_js_object : Ident.t -> unit 

val reset : unit -> unit

val create_tmp :  ?name:string -> unit -> Ident.t

val make_unused : unit -> Ident.t 



(**
   Invariant: if name is not converted, the reference should be equal
*)
val convert : string -> string
val property_no_need_convert : string -> bool 

val undefined : Ident.t 
val is_js_or_global : Ident.t -> bool
 val nil : Ident.t 


val compare : Ident.t -> Ident.t -> int
val equal : Ident.t -> Ident.t -> bool 
