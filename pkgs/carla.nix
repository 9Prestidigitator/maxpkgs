{
  upstreamCarla,
  which,
}:
upstreamCarla.overrideAttrs (oldAttrs: {
  postFixup = (oldAttrs.postFixup or "") + ''
    wrapQtApp "$out/lib/carla/carla-bridge-lv2-modgui" \
      --prefix PATH : "$program_PATH:${which}/bin" \
      --prefix PYTHONPATH : "$program_PYTHONPATH" \
      --set PYTHONNOUSERSITE true
  '';
})
