#!/bin/sh -eux

gulp &
cd output && python -m SimpleHTTPServer