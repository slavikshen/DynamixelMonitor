//
//	IKAROS_Serial.cc		Serial IO utilities for the IKAROS project
//
//    Copyright (C) 2006-2010  Christian Balkenius
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//    See http://www.ikaros-project.org/ for more information.
//

#include "IKAROS_Serial.h"

#include <cstdio>
#include <cstring>
#include <cerrno>

#include <fcntl.h>
#include <termios.h>
#include <unistd.h>


#ifdef MAC_OS_X
#include <IOKit/serial/ioss.h>
#include <sys/ioctl.h>
#endif



Serial::Serial(const char * device_name, unsigned long baud_rate)
{
    struct termios options;

    fd = open(device_name, O_RDWR | O_NOCTTY | O_NDELAY);
    if(fd == -1)
        throw SerialException("Could not open serial device.\n", errno);
    
    fcntl(fd, F_SETFL, 0); // blocking
    tcgetattr(fd, &options); // get the current options // TODO: restore on destruction of the object

#ifndef MAC_OS_X
    if(cfsetispeed(&options, baud_rate))
		throw SerialException("Could not set baud rate for input", errno);
    if(cfsetospeed(&options, baud_rate))
		throw SerialException("Could not set baud rate for output", errno);
#endif

    options.c_cflag |= (CS8 | CLOCAL | CREAD);
    options.c_iflag = IGNPAR;
    options.c_oflag = 0;
    options.c_lflag = 0;
    options.c_cc[VMIN]  = 0;
    options.c_cc[VTIME] = 1;    // tenth of seconds allowed between bytes of serial data
                                // but since VMIN = 0 we will wait at most 1/10 s for data then return
    tcflush(fd, TCIOFLUSH);
    tcsetattr(fd, TCSANOW, &options);   // set the options

#ifdef MAC_OS_X
    cfmakeraw(&options); // necessary for ioctl to function; must come after setattr
	const speed_t TGTBAUD = baud_rate;
	int ret = ioctl(fd, IOSSIOSPEED, &TGTBAUD); // sets also non-standard baud rates
	if (ret)
		throw SerialException("Could not set baud rate", errno);
#endif
}



Serial::~Serial()
{
    Close();
}


void
Serial::Flush()
{
    tcflush(fd, TCIOFLUSH);
}



void
Serial::FlushOut()
{
    tcflush(fd, TCOFLUSH);
}



void
Serial::FlushIn()
{
    tcflush(fd, TCOFLUSH);
}



// Send a string.
int
Serial::SendString(const char *sendbuf)
{
    if(fd == -1)
        return 0;
    return write(fd, sendbuf, strlen(sendbuf));
}



// Read characters until we recive character c
int
Serial::ReceiveUntil(char *rcvbuf, char c)
{
    if(fd == -1)
        return 0;

    char *bufptr = rcvbuf;
    int read_bytes, read_bytes_tot = 0, failed_reads = 0;

    while (failed_reads < MAX_FAILED_READS)
    {
        read_bytes = read(fd, bufptr, 1);

        if (read_bytes == 0)
        {
            failed_reads++;
            continue;
        }

        if (read_bytes > 0)
        {
            bufptr += read_bytes;
            read_bytes_tot += read_bytes;
        }

        if (read_bytes < 0)
            break;

        if (bufptr[-1] == c)
            break;
    }

    if (read_bytes_tot == 0)
        return read_bytes;
    else
        return read_bytes_tot;
}



int
Serial::SendBytes(const char *sendbuf, int length)
{
    if(fd == -1)
        return 0;

    int n = write(fd, sendbuf, length);
    
    if(n == -1)
        printf("Could not send bytes", errno);
    
    return n;
}



int Serial::ReceiveBytes(char *rcvbuf, int length)
{
    if(fd == -1)
        return 0;

    char *bufptr = rcvbuf;
    int read_bytes, read_bytes_tot = 0, failed_reads = 0;

    while (failed_reads < MAX_FAILED_READS)
    {
        read_bytes = read(fd, bufptr, length - read_bytes_tot);

        if (read_bytes == 0)
        {
            failed_reads++;
            continue;
        }

        if (read_bytes < 0)
            break;

        bufptr += read_bytes;
        read_bytes_tot += read_bytes;

        if (read_bytes_tot >= length)
            break;
    }

    if (read_bytes_tot == 0)
        return read_bytes;
    else
        return read_bytes_tot;
}



void Serial::Close()
{
    Flush();
    if(fd != -1)
        close(fd);
}

