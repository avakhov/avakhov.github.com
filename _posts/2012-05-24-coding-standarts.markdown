---
layout: post
title: "Разработка стандарта кодирования"
date: 2012-05-24 10:42
comments: true
categories: 
---
![](/assets/9-face/alex.png)

Если вам необходимо разработать стандарт кодирования обязательно прислушайтесь к совету Герба Саттера и
Андрея Александреску. Этот совет я нашел в книге по C++, но его можно применять к любому языку программированию
и к жизни вообще:

<blockquote>
<p>
Скажем кратко: не мелочитесь.
</p>
<footer>
<strong>Герб Саттер, Андрей Александреску</strong>
<cite>Стандарты программирования на&nbsp;C++ (Глава 0. Что не следует стандартизировать)</cite>
</footer>
</blockquote>

Чтобы стало более понятно приведу еще несколько выдержек:

<blockquote>
<ul>
<li>Не следует определять конкретный размер отступа, но следует использовать отступы для подчеркивания структуры программы. Для отступа используйте то количество символов, которое вам нравится, но это количество должно быть одинаково, как минимум, в пределах файла.</li>
<li>Не определяйте конкретную длину строки, но она должна оставлять текст удобочитаемым. Используйте ту длину строки, которая вам по душе, но не злоупотребляйте ею. Исследования показали, что легче всего воспринимается текст, в строке которого находится до десяти слов.</li>
<li>Следует использовать непротиворечивые соглашения об именовании, не слишком мелочно регламентируя его.</li>
</ul>
</blockquote>

По правде говоря Герб и Андрей очень сильно рискуют, говоря, что количество пробелов в отступе не важно.
Это острая тема и нужно обладать сильным духом, чтобы затронуть ее
на вечеринке с коктелями.
В C++ существует 3 фундаментальные школы: 8 пробелов &mdash; кернел си хакеры,
такой огромный отступ удерживает от вложенности больше трех, 4 пробела &mdash; классика С++, 2 пробела &mdash;
неофиты. На прошлой работе проблему размера стандартного отступа разрешили с изяществом
Александра Македонского &mdash; отступ был 3 пробела. Для крупных проектов, где большая вложенность все же
встречается &mdash; это на удивление удобно.

И еще одна цитата, моя любимая (жирным выделил я):

<blockquote>
<figure class="code"><figcaption><span></span></figcaption><div class="highlight"><table><tbody><tr><td class="gutter"><pre class="line-numbers"><span class="line-number">1</span>
<span class="line-number">2</span>
<span class="line-number">3</span>
<span class="line-number">4</span>
<span class="line-number">5</span>
<span class="line-number">6</span>
<span class="line-number">7</span>
<span class="line-number">8</span>
<span class="line-number">9</span>
<span class="line-number">10</span>
<span class="line-number">11</span>
<span class="line-number">12</span>
</pre></td><td class="code"><pre><code class="c++"><span class="line"><span class="c1">// Размещение фигурных скобок</span>
</span><span class="line"><span class="kt">void</span> <span class="n">using_k_and_r_style</span><span class="p">()</span> <span class="p">{</span>
</span><span class="line"><span class="c1">// ...</span>
</span><span class="line"><span class="p">}</span>
</span><span class="line"><span class="kt">void</span> <span class="n">putting_each_brace_on_its_own_line</span><span class="p">()</span>
</span><span class="line"><span class="p">{</span>
</span><span class="line"><span class="c1">// ...</span>
</span><span class="line"><span class="p">}</span>
</span><span class="line"><span class="kt">void</span> <span class="n">or_putting_each_brace_on_its_own_line_indented</span><span class="p">()</span>
</span><span class="line">    <span class="p">{</span>
</span><span class="line"><span class="c1">// ...</span>
</span><span class="line">    <span class="p">}</span>
</span></code></pre></td></tr></tbody></table></div></figure>
<p><strong>Все профессиональные программисты могут легко читать и писать в каждом из этих стилей без каких-либо сложностей.</strong> Но следует быть последовательным. Не размещайте скобки как придется или так, что их размещение будет скрывать вложенность областей видимости, и пытайтесь следовать стилю, принятому в том или ином файле.</p>
</blockquote>

Итак, не мелочитесь!

<center><img src="/assets/9-face/face.png"></center>
