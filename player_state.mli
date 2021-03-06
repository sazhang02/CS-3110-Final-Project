(** Representation of player state data *)

(** The abstract type representing player state *)
type p

(** The abstract type representing player's intended move *)
type move

(** [init_state t bt] is the initial state of the game. In that state
    the character is currently located in the starting position, and
    they have visited only that level. *)
val init_state : Levels.t -> Board.t -> p

(** [final_state t bt] is the initial state of the final level in the
    game. In that state the character is currently located in the
    starting position of the last level in the game. *)
val final_state : Levels.t -> Board.t -> int -> p

(** [get_current_level p] is the identifier of the level in which the
    player currently is located in state [p]. *)
val get_current_level : p -> Levels.level_id

(** [get_current_tile p] is the tile in which the player currently is
    located in state [p]. *)
val get_current_tile : p -> Board.tile

(** [get current_pos p] is the position coordinate in which the player
    currently is located in state [p]. *)
val get_current_pos : p -> Board.coord

(** [get_coins p] is the coin count for the coins that the player
    currently has in state [p]. *)
val get_coins : p -> int

(** [get_coins p] is the step count for the steps that the player took
    in state [p]. *)
val get_steps : p -> int

(** [update m p t bt] is a state after the player has moved and
    interacted with a tile in the levels before the final level. *)
val update : char -> p -> Levels.t -> Board.t -> p

(** [final_level_update m p t bt b_state] is a state after the player
    has moved and interacted with a tile in the final level. *)
val final_level_update :
  char -> p -> Levels.t -> Board.t -> Boss_state.b -> p * Boss_state.b

(** [make_player_state x y tile id coins] is the player state with
    [tile] at coordinate [(x, y)], level at [id], [coin] number of
    coins, and [step] number of steps taken. *)
val make_player_state :
  int -> int -> Board.tile_type -> Levels.level_id -> int -> int -> p
