# Small project to test interactive heaxagonal map tiling

Just trying to learn [Godot](https://godotengine.org/)
Still a work in progress to do when i have some precious time.

## Notes

Heavily Inspired/Copied by [redblobgames](https://www.redblobgames.com/grids/hexagons/) and [HexMap](https://github.com/droxpopuli/HexMap) and an [Aecert
](https://www.twitch.tv/aecert)'s stream

The Floor staticBody is there only for the mouse ray casting. That is why it has the visibility turned off.

Each time a block is put near 3 others neighbors, all of them will grow by some amount. I wanted to only affect the 3 direct neighbors but there is a reference problem, even with duplicating the scene and making them uniques.


## Navigation

Rotate the camera with the a, d or < , > keys

## Bug?

These kind of things are what defines a language or API. My knowledge is still at rookie level...


