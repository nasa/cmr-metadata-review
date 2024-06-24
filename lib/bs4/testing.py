"""Helper classes for tests."""

import copy
import functools
import unittest
from unittest import TestCase
from bs4 import BeautifulSoup
from bs4.element import (
    CharsetMetaAttributeValue,
    Comment,
    ContentMetaAttributeValue,
    Doctype,
    SoupStrainer,
)
from bs4.builder import HTMLParserTreeBuilder
import pytest

default_builder = HTMLParserTreeBuilder


class SoupTest(unittest.TestCase):
    """Base class for BeautifulSoup tests."""

    @property
    def default_builder(self):
        return default_builder()

    def soup(self, markup, **kwargs):
        """Build a Beautiful Soup object from markup."""
        builder = kwargs.pop('builder', self.default_builder)
        return BeautifulSoup(markup, builder=builder, **kwargs)

    def document_for(self, markup):
        """Turn an HTML fragment into a document."""
        return self.default_builder.test_fragment_to_document(markup)

    def assertSoupEquals(self, to_parse, compare_parsed_to=None):
        """Assert that the parsed soup equals the expected result."""
        builder = self.default_builder
        obj = BeautifulSoup(to_parse, builder=builder)
        if compare_parsed_to is None:
            compare_parsed_to = to_parse
        self.assertEqual(obj.decode(), self.document_for(compare_parsed_to))


class HTMLTreeBuilderSmokeTest(SoupTest):
    """Basic tests for HTML tree builder competence."""

    def assertDoctypeHandled(self, doctype_fragment):
        """Assert that a given doctype string is handled correctly."""
        doctype_str, soup = self._document_with_doctype(doctype_fragment)
        doctype = soup.contents[0]
        self.assertIsInstance(doctype, Doctype)
        self.assertEqual(doctype, doctype_fragment)
        self.assertEqual(str(soup)[:len(doctype_str)], doctype_str)
        self.assertEqual(soup.p.contents[0], 'foo')

    def _document_with_doctype(self, doctype_fragment):
        """Generate and parse a document with the given doctype."""
        doctype = '<!DOCTYPE %s>' % doctype_fragment
        markup = doctype + '\n<p>foo</p>'
        soup = self.soup(markup)
        return doctype, soup

    def test_doctypes(self):
        """Test various doctype declarations."""
        self.assertDoctypeHandled("html")
        self.assertDoctypeHandled(
            'html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"')
        self.assertDoctypeHandled(
            'html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" '
            '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"')
        self.assertDoctypeHandled('foo SYSTEM "http://www.example.com/"')
        self.assertDoctypeHandled('xsl:stylesheet SYSTEM "htmlent.dtd"')
        self.assertDoctypeHandled('xsl:stylesheet PUBLIC "htmlent.dtd"')

    def test_real_xhtml_document(self):
        """Ensure a real XHTML document is parsed correctly."""
        markup = b"""<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>Hello.</title></head>
<body>Goodbye.</body>
</html>"""
        soup = self.soup(markup)
        self.assertEqual(
            soup.encode("utf-8").replace(b"\n", b""),
            markup.replace(b"\n", b""))

    def test_deepcopy(self):
        """Ensure the tree builder can be deep copied."""
        copy.deepcopy(self.default_builder)

    def test_empty_and_unclosed_tags(self):
        """Test handling of empty and unclosed tags."""
        self.assertSoupEquals("<p>", "<p></p>")
        self.assertSoupEquals("<b>", "<b></b>")
        self.assertSoupEquals("<br>", "<br/>")
        soup = self.soup("<br></br>")
        self.assertTrue(soup.br.is_empty_element)
        self.assertEqual(str(soup.br), "<br/>")

    def test_nested_elements(self):
        """Test handling of nested elements."""
        self.assertSoupEquals("<em><em></em></em>")
        markup = "<p>foo<!--foobar-->baz</p>"
        self.assertSoupEquals(markup)
        soup = self.soup(markup)
        comment = soup.find(text="foobar")
        self.assertIsInstance(comment, Comment)

    def test_preserved_whitespace(self):
        """Ensure whitespace is preserved in certain tags."""
        self.assertSoupEquals("<pre>   </pre>")
        self.assertSoupEquals("<textarea> woo  </textarea>")

    def test_angle_brackets_in_attributes(self):
        """Ensure angle brackets in attribute values are escaped."""
        self.assertSoupEquals('<a b="<a>"></a>', '<a b="&lt;a&gt;"></a>')

    def test_entities_in_attributes_and_text(self):
        """Ensure entities in attributes and text are converted to Unicode."""
        expect = u'<p id="pi\N{LATIN SMALL LETTER N WITH TILDE}ata"></p>'
        self.assertSoupEquals('<p id="pi&#241;ata"></p>', expect)
        self.assertSoupEquals('<p id="pi&#xf1;ata"></p>', expect)
        self.assertSoupEquals('<p id="pi&ntilde;ata"></p>', expect)
        expect = u'<p>pi\N{LATIN SMALL LETTER N WITH TILDE}ata</p>'
        self.assertSoupEquals("<p>pi&#241;ata</p>", expect)
        self.assertSoupEquals("<p>pi&#xf1;ata</p>", expect)
        self.assertSoupEquals("<p>pi&ntilde;ata</p>", expect)
        self.assertSoupEquals("<p>I said &quot;good day!&quot;</p>",
                              '<p>I said "good day!"</p>')

    def test_out_of_range_entity(self):
        """Ensure out-of-range entities are replaced with a replacement character."""
        expect = u"\N{REPLACEMENT CHARACTER}"
        self.assertSoupEquals("&#10000000000000;", expect)
        self.assertSoupEquals("&#x10000000000000;", expect)
        self.assertSoupEquals("&#1000000000;", expect)

    def test_basic_namespaces(self):
        """Test handling of basic namespaces."""
        markup = b'<html xmlns="http://www.w3.org/1999/xhtml" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg"><head></head><body><mathml:msqrt>4</mathml:msqrt><b svg:fill="red"></b></body></html>'
        soup = self.soup(markup)
        self.assertEqual(markup, soup.encode())
        html = soup.html
        self.assertEqual('http://www.w3.org/1999/xhtml', soup.html['xmlns'])
        self.assertEqual(
            'http://www.w3.org/1998/Math/MathML', soup.html['xmlns:mathml'])
        self.assertEqual(
            'http://www.w3.org/2000/svg', soup.html['xmlns:svg'])

    def test_multivalued_attribute_value(self):
        """Ensure multi-valued attribute values become lists."""
        markup = b'<a class="foo bar">'
        soup = self.soup(markup)
        self.assertEqual(['foo', 'bar'], soup.a['class'])

    def test_soupstrainer(self):
        """Ensure parsers can work with SoupStrainers."""
        strainer = SoupStrainer("b")
        soup = self.soup("A <b>bold</b> <meta/> <i>statement</i>",
                         parse_only=strainer)
        self.assertEqual(soup.decode(), "<b>bold</b>")

    def test_single_quote_attribute_values(self):
        """Ensure single quote attribute values become double quotes."""
        self.assertSoupEquals("<foo attr='bar'></foo>",
                              '<foo attr="bar"></foo>')

    def test_attribute_values_with_nested_quotes(self):
        """Ensure attribute values with nested quotes are handled correctly."""
        text = """<foo attr='bar "brawls" happen'>a</foo>"""
        self.assertSoupEquals(text)
        soup = self.soup(text)
        soup.foo['attr'] = 'Brawls happen at "Bob\'s Bar"'
        self.assertSoupEquals(
            soup.foo.decode(),
            """<foo attr="Brawls happen at &quot;Bob\'s Bar&quot;">a</foo>""")

    def test_ampersand_in_attribute_value(self):
        """Ensure ampersand in attribute value is escaped."""
        self.assertSoupEquals('<this is="really messed up & stuff"></this>',
                              '<this is="really messed up &amp; stuff"></this>')
        self.assertSoupEquals(
            '<a href="http://example.org?a=1&b=2;3">foo</a>',
            '<a href="http://example.org?a=1&amp;b=2;3">foo</a>')
        self.assertSoupEquals('<a href="http://example.org?a=1&amp;b=2;3"></a>')

    def test_entities_in_strings(self):
        """Ensure entities in strings are converted during parsing."""
        text = "<p>&lt;&lt;sacr&eacute;&#32;bleu!&gt;&gt;</p>"
        expected = u"<p>&lt;&lt;sacr\N{LATIN SMALL LETTER E WITH ACUTE} bleu!&gt;&gt;</p>"
        self.assertSoupEquals(text, expected)

    def test_smart_quotes_converted(self):
        """Ensure Microsoft smart quotes are converted to Unicode characters."""
        quote = b"<p>\x91Foo\x92</p>"
        soup = self.soup(quote)
        self.assertEqual(
            soup.p.string,
            u"\N{LEFT SINGLE QUOTATION MARK}Foo\N{RIGHT SINGLE QUOTATION MARK}")

    def test_non_breaking_spaces(self):
        """Ensure non-breaking spaces are converted to Unicode."""
        soup = self.soup("<a>&nbsp;&nbsp;</a>")
        self.assertEqual(soup.a.string, u"\N{NO-BREAK SPACE}" * 2)

    def test_entities_converted_on_output(self):
        """Ensure entities are converted on the way out."""
        text = "<p>&lt;&lt;sacr&eacute;&#32;bleu!&gt;&gt;</p>"
        expected = u"<p>&lt;&lt;sacr\N{LATIN SMALL LETTER E WITH ACUTE} bleu!&gt;&gt;</p>".encode("utf-8")
        soup = self.soup(text)
        self.assertEqual(soup.p.encode("utf-8"), expected)

    def test_real_iso_latin_document(self):
        """Ensure real ISO-Latin-1 document is parsed and encoded correctly."""
        unicode_html = u'<html><head><meta content="text/html; charset=ISO-Latin-1" http-equiv="Content-type"/></head><body><p>Sacr\N{LATIN SMALL LETTER E WITH ACUTE} bleu!</p></body></html>'
        iso_latin_html = unicode_html.encode("iso-8859-1")
        soup = self.soup(iso_latin_html)
        result = soup.encode("utf-8")
        expected = unicode_html.replace("ISO-Latin-1", "utf-8").encode("utf-8")
        self.assertEqual(result, expected)

    def test_real_shift_jis_document(self):
        """Ensure real Shift-JIS document is parsed correctly."""
        shift_jis_html = (
            b'<html><head></head><body><pre>'
            b'\x82\xb1\x82\xea\x82\xcdShift-JIS\x82\xc5\x83R\x81[\x83f'
            b'\x83B\x83\x93\x83O\x82\xb3\x82\xea\x82\xbd\x93\xfa\x96{\x8c'
            b'\xea\x82\xcc\x83t\x83@\x83C\x83\x8b\x82\xc5\x82\xb7\x81B'
            b'</pre></body></html>')
        unicode_html = shift_jis_html.decode("shift-jis")
        soup = self.soup(unicode_html)
        self.assertEqual(soup.encode("utf-8"), unicode_html.encode("utf-8"))
        self.assertEqual(soup.encode("euc_jp"), unicode_html.encode("euc_jp"))

    def test_real_hebrew_document(self):
        """Ensure real Hebrew document is parsed correctly."""
        hebrew_document = b'<html><head><title>Hebrew (ISO 8859-8) in Visual Directionality</title></head><body><h1>Hebrew (ISO 8859-8) in Visual Directionality</h1>\xed\xe5\xec\xf9</body></html>'
        soup = self.soup(hebrew_document, from_encoding="iso8859-8")
        self.assertEqual(soup.original_encoding, 'iso8859-8')
        self.assertEqual(
            soup.encode('utf-8'),
            hebrew_document.decode("iso8859-8").encode("utf-8"))

    def test_meta_tag_reflects_current_encoding(self):
        """Ensure meta tag reflects the current encoding."""
        meta_tag = ('<meta content="text/html; charset=x-sjis" '
                    'http-equiv="Content-type"/>')
        shift_jis_html = (
            '<html><head>\n%s\n'
            '<meta http-equiv="Content-language" content="ja"/>'
            '</head><body>Shift-JIS markup goes here.') % meta_tag
        soup = self.soup(shift_jis_html)
        parsed_meta = soup.find('meta', {'http-equiv': 'Content-type'})
        content = parsed_meta['content']
        self.assertEqual('text/html; charset=x-sjis', content)
        self.assertTrue(isinstance(content, ContentMetaAttributeValue))
        self.assertEqual('text/html; charset=utf8', content.encode("utf8"))

    def test_html5_style_meta_tag(self):
        """Ensure HTML5 style meta tag reflects current encoding."""
        meta_tag = ('<meta id="encoding" charset="x-sjis" />')
        shift_jis_html = (
            '<html><head>\n%s\n'
            '<meta http-equiv="Content-language" content="ja"/>'
            '</head><body>Shift-JIS markup goes here.') % meta_tag
        soup = self.soup(shift_jis_html)
        parsed_meta = soup.find('meta', id="encoding")
        charset = parsed_meta['charset']
        self.assertEqual('x-sjis', charset)
        self.assertTrue(isinstance(charset, CharsetMetaAttributeValue))
        self.assertEqual('utf8', charset.encode("utf8"))

    def test_tag_with_no_attributes(self):
        """Ensure a tag with no attributes can have attributes added."""
        data = self.soup("<a>text</a>")
        data.a['foo'] = 'bar'
        self.assertEqual('<a foo="bar">text</a>', data.a.decode())


class XMLTreeBuilderSmokeTest(SoupTest):
    """Basic tests for XML tree builder competence."""

    def test_docstring_generated(self):
        """Ensure a docstring is generated with the correct encoding."""
        soup = self.soup("<root/>")
        self.assertEqual(
            soup.encode(), b'<?xml version="1.0" encoding="utf-8"?>\n<root/>')

    def test_real_xhtml_document(self):
        """Ensure a real XHTML document is parsed correctly."""
        markup = b"""<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>Hello.</title></head>
<body>Goodbye.</body>
</html>"""
        soup = self.soup(markup)
        self.assertEqual(soup.encode("utf-8"), markup)

    def test_docstring_includes_correct_encoding(self):
        """Ensure docstring includes the correct encoding."""
        soup = self.soup("<root/>")
        self.assertEqual(
            soup.encode("latin1"),
            b'<?xml version="1.0" encoding="latin1"?>\n<root/>')

    def test_large_xml_document(self):
        """Ensure a large XML document is parsed and encoded correctly."""
        markup = (b'<?xml version="1.0" encoding="utf-8"?>\n<root>'
                  + b'0' * (2**12)
                  + b'</root>')
        soup = self.soup(markup)
        self.assertEqual(soup.encode("utf-8"), markup)

    def test_tags_are_empty_element_if_and_only_if_they_are_empty(self):
        """Ensure tags are empty elements if and only if they are empty."""
        self.assertSoupEquals("<p>", "<p/>")
        self.assertSoupEquals("<p>foo</p>")

    def test_namespaces_are_preserved(self):
        """Ensure namespaces are preserved."""
        markup = '<root xmlns:a="http://example.com/" xmlns:b="http://example.net/"><a:foo>This tag is in the a namespace</a:foo><b:foo>This tag is in the b namespace</b:foo></root>'
        soup = self.soup(markup)
        root = soup.root
        self.assertEqual("http://example.com/", root['xmlns:a'])
        self.assertEqual("http://example.net/", root['xmlns:b'])


class HTML5TreeBuilderSmokeTest(HTMLTreeBuilderSmokeTest):
    """Smoke test for a tree builder that supports HTML5."""

    def test_real_xhtml_document(self):
        """Skip XHTML document test for HTML5 parsers."""
        pass

    def test_html_tags_have_namespace(self):
        """Ensure HTML tags have the correct namespace."""
        markup = "<a>"
        soup = self.soup(markup)
        self.assertEqual("http://www.w3.org/1999/xhtml", soup.a.namespace)

    def test_svg_tags_have_namespace(self):
        """Ensure SVG tags have the correct namespace."""
        markup = '<svg><circle/></svg>'
        soup = self.soup(markup)
        namespace = "http://www.w3.org/2000/svg"
        self.assertEqual(namespace, soup.svg.namespace)
        self.assertEqual(namespace, soup.circle.namespace)

    def test_mathml_tags_have_namespace(self):
        """Ensure MathML tags have the correct namespace."""
        markup = '<math><msqrt>5</msqrt></math>'
        soup = self.soup(markup)
        namespace = 'http://www.w3.org/1998/Math/MathML'
        self.assertEqual(namespace, soup.math.namespace)
        self.assertEqual(namespace, soup.msqrt.namespace)


def skipIf(condition, reason):
   """Conditionally skip a test."""
   def nothing(test, *args, **kwargs):
       return None

   def decorator(test_item):
       if condition:
           return nothing
       else:
           return test_item

   return decorator
