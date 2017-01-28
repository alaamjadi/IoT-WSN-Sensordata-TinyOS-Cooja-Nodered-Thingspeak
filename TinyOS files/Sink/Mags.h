#ifndef MAGS_H
#define MAGS_H

typedef nx_struct mags_msg {
  nx_uint16_t datat;
  nx_uint16_t datah;
} mags_msg_t;

typedef nx_struct mag_msg {
  nx_uint8_t msg_type;
  nx_uint16_t data;
} mag_msg_t;

enum {
  SERIAL_MSG = 0x89,
  RADIO_MSG = 6,
};

#endif