#include "board.h"

int main(void)
{
    board_init();
    for (;;) {
        board_led_toggle();
        board_delay_ms(500);
    }
}
