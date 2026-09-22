# Avalhla user systemd units

Install on a fresh machine:

    mkdir -p ~/.config/systemd/user
    cp systemd/ava-reflect.service ~/.config/systemd/user/
    cp systemd/ava-reflect.timer   ~/.config/systemd/user/
    systemctl --user daemon-reload
    systemctl --user enable --now ava-reflect.timer

Check:

    systemctl --user list-timers ava-reflect.timer
    systemctl --user status ava-reflect.timer

Run now:

    systemctl --user start ava-reflect.service
    tail -n 20 ~/.ai-memory/reflections/last-run.log
