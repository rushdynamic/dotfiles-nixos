const fetchQuote = async () => {
    try {
        const res = await fetch("https://api.kanye.rest/");
        const data = await res.json();
        console.log(data.quote);
    } catch {
        console.log("Kanye: Error")
    }
}

fetchQuote();