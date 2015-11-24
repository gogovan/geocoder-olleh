## Way to send out - valid request

* Request URL : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22UTF-8_Address%22,%22s%22=%22AN%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`

* "s"="AN" : Return both of old and new addresses
* "sr":"RANK" : Give high priority to the accuracy
* "places":"5" : Number of address that want to get returned
* "option":"2" : Distance based result alignment from current location
* "isaddr":"0", "isaddr":"1" : Search from address DB or not (0 : No, 1 : Yes)

## Search queries from end users

1) POI search

* KeyWord1 : 국민은행
* KeyWord2 : 서울 국민은행
* KeyWord3 : 서초동 강남미래타워

- Valid query1 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EA%25B5%25AD%25EB%25AF%25BC%25EC%259D%2580%25ED%2596%2589%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`
- Valid query2 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2584%259C%25EC%259A%25B8+%25EA%25B5%25AD%25EB%25AF%25BC%25EC%259D%2580%25ED%2596%2589%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`
- Valid query3 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2584%259C%25EC%25B4%2588%25EB%258F%2599+%25EA%25B0%2595%25EB%2582%25A8%25EB%25AF%25B8%25EB%259E%2598%25ED%2583%2580%25EC%259B%258C%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`

2) Old address search (With Gibun or without Gibun)

* KeyWord1 : 삼평동
* KeyWord2 : 삼평동 689
* KeyWord3 : 분당구 689
* KeyWord4 : 분당구 삼평동 689
* KeyWord5 : 성남시 분당구 삼평동 689
* KeyWord6 : 경기 성남시 분당구 삼평동 689
* KeyWord7 : 경기도 성남시 분당구 삼평동 689

- Valid query1 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2582%25BC%25ED%258F%2589%25EB%258F%2599%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`
- Valid query2 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2582%25BC%25ED%258F%2589%25EB%258F%2599+689%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`
- Valid query3 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EB%25B6%2584%25EB%258B%25B9%25EA%25B5%25AC+689%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%221%22}`
- Valid query4 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EB%25B6%2584%25EB%258B%25B9%25EA%25B5%25AC+%25EC%2582%25BC%25ED%258F%2589%25EB%258F%2599+689%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`
- Valid query5 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2584%25B1%25EB%2582%25A8%25EC%258B%259C+%25EB%25B6%2584%25EB%258B%25B9%25EA%25B5%25AC+%25EC%2582%25BC%25ED%258F%2589%25EB%258F%2599+689%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`
- Valid query6 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EA%25B2%25BD%25EA%25B8%25B0+%25EC%2584%25B1%25EB%2582%25A8%25EC%258B%259C+%25EB%25B6%2584%25EB%258B%25B9%25EA%25B5%25AC+%25EC%2582%25BC%25ED%258F%2589%25EB%258F%2599+689%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`
- Valid query7 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EA%25B2%25BD%25EA%25B8%25B0%25EB%258F%2584+%25EC%2584%25B1%25EB%2582%25A8%25EC%258B%259C+%25EB%25B6%2584%25EB%258B%25B9%25EA%25B5%25AC+%25EC%2582%25BC%25ED%258F%2589%25EB%258F%2599+689%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`

3) New address search (With street number or without street number)

* KeyWord1 : 사임당로
* KeyWord2 : 사임당로 174
* KeyWord3 : 서초구 사임당로 174
* KeyWord4 : 서울 서초구 사임당로 174
* KeyWord5 : 서울시 서초구 사임당로 174

- Valid query1 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2582%25AC%25EC%259E%2584%25EB%258B%25B9%25EB%25A1%259C%22,%22s%22=%22AN%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%221%22}`
- Valid query2 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2582%25AC%25EC%259E%2584%25EB%258B%25B9%25EB%25A1%259C+174%22,%22s%22=%22AN%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%221%22}`
- Valid query3 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2584%259C%25EC%25B4%2588%25EB%258F%2599+%25EC%2582%25AC%25EC%259E%2584%25EB%258B%25B9%25EB%25A1%259C+174%22,%22s%22=%22AN%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%221%22}`
- Valid query4 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2584%259C%25EC%259A%25B8+%25EC%2584%259C%25EC%25B4%2588%25EB%258F%2599+%25EC%2582%25AC%25EC%259E%2584%25EB%258B%25B9%25EB%25A1%259C+174%22,%22s%22=%22AN%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%221%22}`
- Valid query5 : `http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22%25EC%2584%259C%25EC%259A%25B8%25EC%258B%259C+%25EC%2584%259C%25EC%25B4%2588%25EB%258F%2599+%25EC%2582%25AC%25EC%259E%2584%25EB%258B%25B9%25EB%25A1%259C+174%22,%22s%22=%22AN%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%221%22}`

## Data to be taken

* Old address : address from "ADDR" or "M_ADDR1" + "M_ADDR2"
* New address : address from "NEW_ADDR"

* Coordinates
"Y":"1933916.06","H_CODE":"4113565500","X":"965566.75"

* Procedure to query address

Search address with "s"="AN" & "isaddr":"1"
`http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22UTF-8_Address%22,%22s%22=%22AN%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%221%22}`

Search address with "isaddr":"1"
`http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22UTF-8_Address%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%221%22}`

Search address with "isaddr":"0"
`http://openapi.kt.com/maps/search/km2_LocalSearch?params={%22query%22:%22UTF-8_Address%22,%22sr%22:%22RANK%22,%22places%22:%225%22,%22option%22:%222%22,%22timestamp%22:%2220120413092033765%22,%22isaddr%22:%220%22}`

If all above 3 returns no address it means there is no available results for the * keyword
