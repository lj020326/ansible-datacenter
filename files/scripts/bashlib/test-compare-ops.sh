#!/usr/bin/env bash

## source: https://gist.github.com/webmaster128/9e52e1cec044883fee80

echo "Test 1: '<'"
if [[ 13.10 < 14.04 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 13.10 < 14.04.1 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 14.04 < 14.04.1 ]]; then echo "ok"; else echo "fail"; fi;
echo

echo "Test 2: '-lt'"
if [[ 13.10 -lt 14.04 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 13.10 -lt 14.04.1 ]]; then echo "ok"; else echo "fail"; fi;
echo

echo "Test 3: '-le'"
if [[ 13.10 -le 14.04 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 13.10 -le 14.04.1 ]]; then echo "ok"; else echo "fail"; fi;
echo

echo "Test 4: '=='"
if [[ 13.10 == 13.10 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 14.04.1 == 14.04.1 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 13.10 == 14.04 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 13.10 == 14.04.1 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 14.04 == 14.04.1 ]]; then echo "fail"; else echo "ok"; fi;
echo

echo "Test 5: '>'"
if [[ 13.10 > 14.04 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 13.10 > 14.04.1 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 14.04 > 13.10 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 14.04.1 > 13.10 ]]; then echo "ok"; else echo "fail"; fi;
echo

echo "Test 6: '-gt'"
if [[ 13.10 -gt 14.04 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 13.10 -gt 14.04.1 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 14.04 -gt 13.10 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 14.04.1 -gt 13.10 ]]; then echo "ok"; else echo "fail"; fi;
echo

echo "Test 7: '-ge'"
if [[ 13.10 -ge 14.04 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 13.10 -ge 14.04.1 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 14.04 -ge 13.10 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 14.04.1 -ge 13.10 ]]; then echo "ok"; else echo "fail"; fi;
echo

echo "Test 8: '>='"
if [[ 13.10 >= 14.04 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 13.10 >= 14.04.1 ]]; then echo "fail"; else echo "ok"; fi;
if [[ 14.04 >= 13.10 ]]; then echo "ok"; else echo "fail"; fi;
if [[ 14.04.1 >= 13.10 ]]; then echo "ok"; else echo "fail"; fi;
echo
