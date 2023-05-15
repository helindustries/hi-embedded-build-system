LOGIC_ARGS=""
if [ "$LOGIC_FOCUS" == "YES" ]; then
    LOGIC_ARGS="-focus"
fi

if [ "$LOGIC_ENABLED" == "YES" ]; then
    $HOME/.local/scripts/run_logic.sh $LOGIC_ARGS &
fi

#ps -A | grep run_logic.sh | grep -v grep | sed -E 's%([0-9]+).*%\1%' | xargs -I {} kill {}
