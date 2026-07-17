{
  upstreamCarla,
  which,
  pipewireJack,
}:
upstreamCarla.overrideAttrs (oldAttrs: {
  postFixup = (oldAttrs.postFixup or "") + ''
    for program in "$out"/bin/*; do
      if [ -f "$program" ] && [ -x "$program" ]; then
        wrapProgram "$program" \
          --prefix LD_LIBRARY_PATH : "${pipewireJack}/lib"
      fi
    done

    wrapQtApp "$out/lib/carla/carla-bridge-lv2-modgui" \
      --prefix PATH : "$program_PATH:${which}/bin" \
      --prefix PYTHONPATH : "$program_PYTHONPATH" \
      --set PYTHONNOUSERSITE true
  '';
})
