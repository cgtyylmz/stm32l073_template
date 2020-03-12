#include "stm32l0xx.h"
/*
 * ConfigureGPIO()
 */
void ConfigureGPIO (void)
{
  /* enable the peripheral clock of GPIOA */
  RCC->IOPENR |= RCC_IOPENR_GPIOCEN;

  /* select output mode on PA5 */
  GPIOC->MODER = (GPIOC->MODER & ~(GPIO_MODER_MODE13)) | (GPIO_MODER_MODE13_0);
}

/*
 * main function
 */

int main(void)
{
  ConfigureGPIO();

  while(1)
    {
      /* toogle pin PA5 */
      GPIOC->ODR ^= (1 << 13);

    }

  return 0;
}
