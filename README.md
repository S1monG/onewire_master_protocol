### 1-WIRE OPERATIONS

| Operation   | Description                                         | Implementation                                                                 |
|-------------|-----------------------------------------------------|---------------------------------------------------------------------------------|
| Write 1 bit | Send a ‘1’ bit to the 1-Wire slaves (Write 1 time slot) | Drive bus low, delay 6µs  <br> Release bus, delay 64µs                        |
| Write 0 bit | Send a ‘0’ bit to the 1-Wire slaves (Write 0 time slot) | Drive bus low, delay 60µs <br> Release bus, delay 10µs                        |
| Read bit    | Read a bit from the 1-Wire slaves (Read time slot) | Drive bus low, delay 6µs  <br> Release bus, delay 9µs  <br> Sample bus to read bit from slave <br> Delay 55µs |
| Reset       | Reset the 1-Wire bus slave devices and ready them for a command | Drive bus low, delay 480µs <br> Release bus, delay 70µs <br> Sample bus, 0 = device(s) present, 1 = no device present <br> Delay 410µs |
