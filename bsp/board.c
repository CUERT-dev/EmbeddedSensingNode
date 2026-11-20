#include "board.h"

#define RCC_AHB2ENR (*(volatile uint32_t *)0x4002104CU)
#define GPIOA_MODER (*(volatile uint32_t *)0x48000000U)
#define GPIOA_ODR (*(volatile uint32_t *)0x48000014U)
#define SYST_CSR (*(volatile uint32_t *)0xE000E010U)
#define SYST_RVR (*(volatile uint32_t *)0xE000E014U)
#define SYST_CVR (*(volatile uint32_t *)0xE000E018U)

#define HSI_HZ 16000000U
#define LED_PIN 5U

static volatile uint32_t ticks;

void SysTick_Handler(void)
{
    ticks++;
}

void board_init(void)
{
    RCC_AHB2ENR |= 1U;
    (void)RCC_AHB2ENR;
    GPIOA_MODER = (GPIOA_MODER & ~(3U << (LED_PIN * 2U))) | (1U << (LED_PIN * 2U));
    SYST_RVR = (HSI_HZ / 1000U) - 1U;
    SYST_CVR = 0U;
    SYST_CSR = 7U;
}

void board_led_toggle(void)
{
    GPIOA_ODR ^= 1U << LED_PIN;
}

void board_delay_ms(uint32_t ms)
{
    uint32_t start = ticks;
    while ((ticks - start) < ms) {
        __asm volatile("wfi");
    }
}
