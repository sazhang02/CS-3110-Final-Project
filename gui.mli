(** Representation of gui data *)

(** The type representing the position of a coordinates on the GUI
    window *)
type coords = {
  x : int;
  y : int;
}

(** [window_size] is the dimensions of the window. Required: If the
    string is non-empty, it must start with a space and then follow the
    format widthxheight. *)
val window_size : string

(** [window_title] is name of the window. *)
val window_title : string

(** [load_png png_name] is the Images.t equivalent of the png file with
    name [png_name]. Required: [png_name] is the name of the directory
    reference. For example, if png.png is in the same directory, a valid
    [png_name] is "png.png". If png.pngis in folder "images" which is in
    the same directory, a valid [png_name] is "images/png.png". *)
val load_png : string -> Images.t

(** [img_width img] is width of [img] in pixels. *)
val img_width : Images.t -> int

(** [img_height img] is height of [img] in pixels. *)
val img_height : Images.t -> int

(** [draw_at_coords img loc] draws [img] at [loc] on the GUI window. *)
val draw_at_coords : Graphics.image -> coords -> unit

(** [update_player new_img old_img new_loc old_loc] replaces the image
    at [old_loc] with [old_img] and [new_loc] with [new_img]. *)
val update_player :
  Graphics.image -> Graphics.image -> coords -> coords -> unit