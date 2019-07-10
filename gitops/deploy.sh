#!/bin/bash

rvm use default

echo `pwd`

civo apikey current production
civo instance list
