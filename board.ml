type coord = {
  x : int;
  y : int;
}

type orientation =
  | Left
  | Right
  | Up
  | Down

type color =
  | Green
  | Red
  | Gold
  | Blue
  | Black

type room = {
  bl_start : coord;
  (* bottom left*)
  tr_end : coord; (* top right *)
}

type pipe = {
  end_coords : coord;
  orientation : orientation;
  color : color;
}

type tile_type =
  | Wall
  | Pipe of pipe
  | Entrance of orientation
  | Exit of orientation
  | Empty
  | Coin

type tile = {
  coords : coord;
  tile_type : tile_type;
}

type t = tile array

let get_x pos = pos.x

let get_y pos = pos.y

let make_coord x y = { x; y }

let dimx = 16

let dimy = 16

let get_tile_coords tile = tile.coords

let get_tile_type tile = tile.tile_type

let blank = { coords = { x = 0; y = 0 }; tile_type = Wall }

let index_of_coord dimx coord =
  match coord with { x; y } -> x + (dimx * y)

let coord_of_index dimx index = { x = index mod dimx; y = index / dimx }

(** [replace_empty i t] replaces the tile at index [i] in layout [t]
    with an empty tile. *)
let replace_empty index t =
  t.(index) <- { coords = coord_of_index dimx index; tile_type = Empty }

let make_tile tile_type coords = { coords; tile_type }

let set_tile tile t = t.(index_of_coord dimx tile.coords) <- tile

let get_tile i (t : t) = t.(i)

let get_tile_c (coord : coord) (t : t) = t.(index_of_coord dimx coord)

let get_size (t : t) = Array.length t

let get_tile_orientation tile =
  match tile.tile_type with
  | Entrance o -> o
  | Exit o -> o
  | Pipe pipe -> pipe.orientation
  | _ -> failwith ""

let room_of_coords bottom_left_start top_right_end =
  { bl_start = bottom_left_start; tr_end = top_right_end }

let get_pipe_end_of_tile tile =
  match tile.tile_type with
  | Pipe p -> p.end_coords
  | _ -> failwith "Not a pipe"

let get_pipe_color pipe = pipe.color

(** [reflect_green orientation start] is the [coord] in front of the
    exit of a green pipe at [start] facing [orientation]. *)
let reflect_green orientation start : coord =
  match orientation with
  | Right -> { x = dimx - start.x - 2; y = start.y }
  | Left -> { x = dimx - start.x; y = start.y }
  | Up -> { x = start.x; y = dimy - start.y - 2 }
  | Down -> { x = start.x; y = dimy - start.y }

(** [reflect_red o start] is the [coord] in front of the exit of a red
    pipe at [start] facing [o]. *)
let reflect_red orientation start : coord =
  match orientation with
  | Right -> { x = start.x + 1; y = dimy - start.y - 1 }
  | Left -> { x = start.x - 1; y = dimy - start.y - 1 }
  | Up -> { x = dimx - start.x - 1; y = start.y + 1 }
  | Down -> { x = dimx - start.x - 1; y = start.y - 1 }

(** [reflect_gold o start] is the [coord] in front of the exit of a gold
    pipe at [start] facing [o]. *)
let reflect_gold orientation start =
  match orientation with
  | Right -> { x = dimx - start.x - 2; y = dimy - start.y - 1 }
  | Left -> { x = dimx - start.x; y = dimy - start.y - 1 }
  | Up -> { x = dimx - start.x - 1; y = dimy - start.y - 2 }
  | Down -> { x = dimx - start.x - 1; y = dimy - start.y }

(** [rotate_blue o start] is the [coord] in front of the exit of a blue
    pipe at [start] facing [o]. *)
let rotate_blue orientation start =
  match orientation with
  | Right -> { x = start.y; y = dimx - start.x - 2 }
  | Left -> { x = start.y; y = dimx - start.x }
  | Up -> { x = start.y + 1; y = dimx - start.x - 1 }
  | Down -> { x = start.y - 1; y = dimx - start.x - 1 }

let black_end orientation start =
  match orientation with
  | Right -> { x = start.x + 1; y = start.y }
  | Left -> { x = start.x - 1; y = start.y }
  | Up -> { x = start.x; y = start.y + 1 }
  | Down -> { x = start.x; y = start.y - 1 }

(** [pipe_end s c o] is the [coord] that a pipe at coords [s] facing [o]
    with color [c] leads to. *)
let pipe_end start color orientation =
  match color with
  | Green -> reflect_green orientation start
  | Red -> reflect_red orientation start
  | Gold -> reflect_gold orientation start
  | Blue -> rotate_blue orientation start
  | Black -> black_end orientation start

let make_pipe_tile entrance color orientation =
  let end_coords = pipe_end entrance color orientation in
  let pipe = { end_coords; orientation; color } in
  make_tile (Pipe pipe) entrance

(** [make_room room t] adds [room] to board [t]. *)
let make_room room t =
  for i = room.bl_start.x to room.tr_end.x do
    for j = room.bl_start.y to room.tr_end.y do
      let coord = { x = i; y = j } in
      replace_empty (index_of_coord dimx coord) t
    done
  done;
  t

(* [make_rooms_board rooms t] adds rooms in [rooms] to board [t]. *)
let rec make_rooms_board rooms board =
  match rooms with
  | [] -> board
  | h :: t -> make_rooms_board t (make_room h board)

(** [add_tiles lst t] adds pipe tiles [pipes] in board [t]. Requires:
    the elements of [lst] are Pipe or Coin tiles. *)
let rec add_tiles (tiles : tile list) board =
  match tiles with
  | [] -> board
  | h :: t -> (
      match h.tile_type with
      | Pipe _ | Coin ->
          let i = index_of_coord dimx h.coords in
          board.(i) <- h;
          add_tiles t board
      | _ -> failwith "" )

(** [tile_to_string tile] is the string representation of a tile. *)
let tile_to_string tile =
  match tile.tile_type with
  | Wall -> "W"
  | Pipe p -> (
      match p.orientation with
      | Right -> ">"
      | Left -> "<"
      | Up -> "^"
      | Down -> "v" )
  | Entrance _ -> "I"
  | Exit _ -> "O"
  | Empty -> " "
  | Coin -> "c"

let rec random_item (board : t) =
  let rand_x = Random.int dimx in
  let rand_y = Random.int dimy in
  let coords = { x = rand_x; y = rand_y } in
  print_endline (string_of_int rand_x ^ ", " ^ string_of_int rand_y);
  let tile = get_tile_c coords board in
  print_endline (tile_to_string tile);
  match get_tile_type tile with
  | Empty ->
      let new_tile = { coords; tile_type = Wall (*placeholder*) } in
      set_tile new_tile board;
      board
  | _ -> random_item board

(** [make_board en ex r] makes a board with entrance [en], exit [ex],
    and rooms [r]. *)
let make_board entrance exit rooms =
  let board =
    make_rooms_board rooms
      (let def = Array.make (dimx * dimy) blank in
       for i = 0 to Array.length def - 1 do
         def.(i) <- { coords = coord_of_index dimx i; tile_type = Wall }
       done;
       def)
  in
  set_tile entrance board;
  set_tile exit board;
  board

let alla_board entrance exit rooms pipes coins =
  let board = make_board entrance exit rooms in
  let board = add_tiles pipes board in
  add_tiles coins board

let board_to_string (board : t) =
  let str = ref "\n" in
  for i = 0 to dimy - 1 do
    for j = 0 to dimx - 1 do
      str :=
        !str ^ "|"
        ^ tile_to_string (get_tile_c { x = j; y = dimy - 1 - i } board)
    done;
    str := !str ^ "|\n"
  done;
  !str
