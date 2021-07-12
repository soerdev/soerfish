function fish_right_prompt
  if [ $exit_code != 0 ];
    echo (set_color red) ↵ $exit_code(set_color normal)
  end
end
