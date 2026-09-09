import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../components/gradient_border.dart';
import '../../components/icon.dart';
import '../../components/link_button.dart';
import '../../constants/theme.dart';

class Consulting extends StatelessComponent {
  const Consulting({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'consulting-page', [
          // Hero Section
          div(classes: 'cons-hero', [
            span(classes: 'caption2 text-gradient', [.text('ENTERPRISE SERVICES & CONSULTING')]),
            h1([
              .text('Turn Your Flutter Team into a '),
              br(),
              span(classes: 'text-gradient', [.text('Full-Stack Web Powerhouse')]),
            ]),
            p(classes: 'cons-subtitle', [
              .text(
                'Work directly with Kilian Schulte, creator of Jaspr. We help engineering teams, startups, '
                'and enterprises migrate from Flutter to the web, build production-grade web applications, '
                'and achieve up to 100% code sharing without sacrificing SEO or performance.',
              ),
            ]),
            div(classes: 'cons-hero-actions', [
              LinkButton.filled(
                label: 'Get in Touch with Kilian',
                icon: 'send',
                to: 'mailto:kilian@schultek.dev?subject=Jaspr%20Consulting%20Inquiry',
              ),
              LinkButton.outlined(
                label: 'Read Google Case Study',
                icon: 'arrow-right',
                to: '/case-studies/flutter-dart',
              ),
            ]),
          ]),

          // Trust Banner
          div(classes: 'cons-trust-bar', [
            p(classes: 'trust-label', [.text('Trusted by engineering teams and open source leaders')]),
            div(classes: 'trust-logos', [
              span(classes: 'trust-badge', [.text('Google • Flutter & Dart')]),
              span(classes: 'trust-badge', [.text('Serverpod')]),
              span(classes: 'trust-badge', [.text('LeanCode')]),
              span(classes: 'trust-badge', [.text('Flutter Friends')]),
            ]),
          ]),

          // Why Choose Jaspr (Business ROI)
          div(classes: 'cons-section', [
            div(classes: 'cons-section-header', [
              span(classes: 'caption text-gradient', [.text('The Business Advantage')]),
              h2([.text('Why High-Growth Teams Choose Jaspr')]),
              p([.text('Eliminate the overhead of maintaining two disconnected tech stacks.')]),
            ]),
            div(classes: 'cons-benefits-grid', [
              div(classes: 'cons-benefit-card', [
                div(classes: 'benefit-icon text-gradient', [Icon('sparkles')]),
                h3([.text('100% Skill & Code Reuse')]),
                p([
                  .text(
                    'No need to hire and manage a separate React or Vue team. Your existing Dart and Flutter '
                    'developers can build world-class web applications, sharing models, business logic, and state.',
                  ),
                ]),
              ]),
              div(classes: 'cons-benefit-card', [
                div(classes: 'benefit-icon text-gradient', [Icon('trophy')]),
                h3([.text('True Web SEO & Blazing Speed')]),
                p([
                  .text(
                    'Unlike Flutter Web’s Canvas rendering, Jaspr renders semantic HTML and CSS. '
                    'Your pages load instantly, index perfectly on Google, and achieve top Lighthouse scores.',
                  ),
                ]),
              ]),
              div(classes: 'cons-benefit-card', [
                div(classes: 'benefit-icon text-gradient', [Icon('layers')]),
                h3([.text('Battle-Tested at Google Scale')]),
                p([
                  .text(
                    'Jaspr powers the official flutter.dev, dart.dev, and docs.flutter.dev sites, '
                    'confidently serving millions of active developers every month.',
                  ),
                ]),
              ]),
            ]),
          ]),

          // Core Offerings
          div(classes: 'cons-section', [
            div(classes: 'cons-section-header', [
              span(classes: 'caption text-gradient', [.text('Services')]),
              h2([.text('How We Can Work Together')]),
              p([.text('Tailored packages designed for ambitious companies and engineering teams.')]),
            ]),
            div(classes: 'cons-services-grid', [
              div(classes: 'cons-service-card', [
                span(classes: 'service-number text-gradient', [.text('01')]),
                h3([.text('Flutter-to-Web Migrations')]),
                p([
                  .text(
                    'Migrate your existing Flutter apps, customer portals, or documentation sites '
                    'to native HTML/CSS with Jaspr. We preserve your shared business logic while '
                    'unlocking blazing web performance and full search engine indexability.',
                  ),
                ]),
                ul([
                  li([.text('Codebase audit & migration roadmap')]),
                  li([.text('Component translation & state sharing')]),
                  li([.text('SEO metadata, hydration & SSR setup')]),
                ]),
              ]),
              div(classes: 'cons-service-card', [
                span(classes: 'service-number text-gradient', [.text('02')]),
                h3([.text('Custom Full-Stack Development')]),
                p([
                  .text(
                    'Build high-performance web applications, customer-facing dashboards, '
                    'or interactive developer documentation hubs from scratch with the creator of the framework.',
                  ),
                ]),
                ul([
                  li([.text('Architecture design & implementation')]),
                  li([.text('Backend integrations (Shelf, Serverpod, Dart Frog)')]),
                  li([.text('Interactive UI & responsive design')]),
                ]),
              ]),
              div(classes: 'cons-service-card', [
                span(classes: 'service-number text-gradient', [.text('03')]),
                h3([.text('Architecture & Performance Reviews')]),
                p([
                  .text(
                    'Get an exhaustive expert review of your existing Dart web project. '
                    'We identify bottlenecks, optimize hydration, reduce bundle sizes, '
                    'and implement best practices.',
                  ),
                ]),
                ul([
                  li([.text('Deep-dive bundle & runtime analysis')]),
                  li([.text('SEO and core web vitals optimization')]),
                  li([.text('Actionable recommendations and code patches')]),
                ]),
              ]),
              div(classes: 'cons-service-card', [
                span(classes: 'service-number text-gradient', [.text('04')]),
                h3([.text('Enterprise Advisory & Dedicated SLA')]),
                p([
                  .text(
                    'Ensure your team has direct, priority access to framework support. '
                    'Includes regular architectural steering, priority bug fixes, and hands-on team training.',
                  ),
                ]),
                ul([
                  li([.text('Direct Slack / Discord channel with Kilian')]),
                  li([.text('Guaranteed SLA for issues and feature requests')]),
                  li([.text('Team onboarding & training workshops')]),
                ]),
              ]),
            ]),
          ]),

          // Testimonials Callout
          div(classes: 'cons-section cons-testimonial-section', [
            div(classes: 'cons-testimonial-card', [
              div(classes: 'quote-mark', [.text('“')]),
              p(classes: 'quote-text', [
                .text(
                  'Jaspr is an amazing usage of Dart\'s web stack and a compliment to Flutter web. '
                  'It\'s a great place to start if you want to use HTML and CSS with Dart.',
                ),
              ]),
              div(classes: 'quote-author', [
                div(classes: 'author-name', [.text('Kevin Moore')]),
                div(classes: 'author-role', [.text('Product Manager for Dart and Flutter at Google')]),
              ]),
            ]),
          ]),

          // Final Contact / Lead Form CTA
          div(classes: 'cons-cta-banner', [
            GradientBorder(
              radius: 18,
              child: div(classes: 'cons-cta-content', [
                span(classes: 'caption2 text-gradient', [.text('LET’S BUILD TOGETHER')]),
                h2([.text('Ready to Accelerate Your Web Presence?')]),
                p([
                  .text(
                    'Whether you have a specific migration in mind, need custom development, '
                    'or want an expert opinion on your architecture, let\'s talk.',
                  ),
                ]),
                div(classes: 'cons-contact-options', [
                  div(classes: 'contact-method', [
                    div(classes: 'method-label', [.text('Direct Email')]),
                    a(
                      href: 'mailto:kilian@schultek.dev?subject=Jaspr%20Consulting%20Inquiry',
                      classes: 'method-link animated-underline',
                      [.text('kilian@schultek.dev')],
                    ),
                  ]),
                  div(classes: 'contact-method', [
                    div(classes: 'method-label', [.text('Community Discord')]),
                    a(
                      href: 'https://discord.gg/XGXrGEk4c6',
                      target: .blank,
                      classes: 'method-link animated-underline',
                      [.text('Join 500+ developers')],
                    ),
                  ]),
                ]),
                div(classes: 'cons-cta-buttons', [
                  LinkButton.filled(
                    label: 'Email Kilian Directly',
                    icon: 'send',
                    to: 'mailto:kilian@schultek.dev?subject=Jaspr%20Consulting%20Inquiry',
                  ),
                  LinkButton.outlined(
                    label: 'Back to Showcase',
                    icon: 'arrow-right',
                    to: '/#showcase',
                  ),
                ]),
              ]),
            ),
          ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.consulting-page', [
      css('&').styles(
        display: .flex,
        flexDirection: .column,
        alignItems: .center,
        padding: .only(top: 8.rem, bottom: 6.rem),
        boxSizing: .borderBox,
      ),
      css('.cons-hero', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          textAlign: .center,
          maxWidth: 54.rem,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 3.5.rem),
          boxSizing: .borderBox,
        ),
        css('h1').styles(
          fontSize: 3.4.rem,
          fontWeight: .w800,
          lineHeight: 1.15.em,
          margin: .only(top: 0.6.rem, bottom: 1.2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.cons-subtitle').styles(
          fontSize: 1.25.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 2.2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.cons-hero-actions').styles(
          display: .flex,
          flexWrap: .wrap,
          gap: .all(1.rem),
          justifyContent: .center,
        ),
      ]),
      css('.cons-trust-bar', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          padding: .symmetric(vertical: 2.rem, horizontal: contentPadding),
          margin: .only(bottom: 5.rem),
          border: .symmetric(
            vertical: .new(color: borderColor, width: 1.px),
          ),
          width: 100.percent,
          boxSizing: .borderBox,
          backgroundColor: surfaceLow,
        ),
        css('.trust-label').styles(
          fontSize: 0.85.rem,
          color: textDim,
          textTransform: .upperCase,
          letterSpacing: 0.08.em,
          fontWeight: .w600,
          margin: .only(bottom: 1.2.rem),
        ),
        css('.trust-logos').styles(
          display: .flex,
          flexWrap: .wrap,
          gap: .all(1.2.rem),
          justifyContent: .center,
          alignItems: .center,
        ),
        css('.trust-badge').styles(
          padding: .symmetric(horizontal: 1.2.rem, vertical: 0.5.rem),
          radius: .circular(20.px),
          backgroundColor: surface,
          border: .all(color: borderColor, width: 1.px),
          fontSize: 0.95.rem,
          fontWeight: .w600,
          color: textBlack,
        ),
      ]),
      css('.cons-section', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          maxWidth: maxContentWidth,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 5.5.rem),
          boxSizing: .borderBox,
          width: 100.percent,
        ),
      ]),
      css('.cons-section-header', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          textAlign: .center,
          margin: .only(bottom: 3.5.rem),
        ),
        css('h2').styles(
          fontSize: 2.4.rem,
          fontWeight: .w700,
          margin: .only(top: 0.4.rem, bottom: 0.6.rem),
        ),
        css('p').styles(
          fontSize: 1.1.rem,
          color: textDim,
          margin: .zero,
        ),
      ]),
      css('.cons-benefits-grid', [
        css('&').styles(
          display: .grid,
          width: 100.percent,
          gap: .all(2.rem),
          raw: {'grid-template-columns': 'repeat(auto-fit, minmax(280px, 1fr))'},
        ),
      ]),
      css('.cons-benefit-card', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          padding: .all(2.2.rem),
          backgroundColor: surface,
          radius: .circular(14.px),
          border: .all(color: borderColor, width: 1.px),
          boxSizing: .borderBox,
        ),
        css('.benefit-icon').styles(
          fontSize: 2.rem,
          color: primaryMid,
          margin: .only(bottom: 1.2.rem),
        ),
        css('h3').styles(
          fontSize: 1.35.rem,
          fontWeight: .w600,
          color: textBlack,
          margin: .only(top: .zero, bottom: 0.8.rem),
        ),
        css('p').styles(
          fontSize: 1.02.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .zero,
        ),
      ]),
      css('.cons-services-grid', [
        css('&').styles(
          display: .grid,
          width: 100.percent,
          gap: .all(2.rem),
          raw: {'grid-template-columns': 'repeat(auto-fit, minmax(320px, 1fr))'},
        ),
      ]),
      css('.cons-service-card', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          padding: .all(2.4.rem),
          backgroundColor: surface,
          border: .all(color: borderColor, width: 1.px),
          radius: .circular(14.px),
          height: 100.percent,
          boxSizing: .borderBox,
          transition: .new('all', duration: 200.ms, curve: .easeInOut),
        ),
        css('&:hover').styles(
          border: .all(color: borderColor2, width: 1.px),
          transform: .translate(y: (-2).px),
          shadow: BoxShadow(
            offsetX: 0.px,
            offsetY: 4.px,
            blur: 12.px,
            color: Color.rgba(0, 0, 0, 0.05),
          ),
        ),
        css('.service-number').styles(
          fontSize: 1.5.rem,
          fontWeight: .w800,
          margin: .only(bottom: 0.8.rem),
        ),
        css('h3').styles(
          fontSize: 1.4.rem,
          fontWeight: .w700,
          color: textBlack,
          margin: .only(top: .zero, bottom: 0.8.rem),
        ),
        css('p').styles(
          fontSize: 1.02.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 1.5.rem),
        ),
        css('ul').styles(
          padding: .only(left: 1.2.rem),
          margin: .only(top: .auto),
          fontSize: 0.95.rem,
          color: textDim,
          lineHeight: 1.7.em,
        ),
        css('li').styles(margin: .only(bottom: 0.3.rem)),
      ]),
      css('.cons-testimonial-section', [
        css('&').styles(alignItems: .center),
      ]),
      css('.cons-testimonial-card', [
        css('&').styles(
          maxWidth: 48.rem,
          padding: .all(3.rem),
          backgroundColor: surfaceLow,
          radius: .circular(16.px),
          border: .all(color: borderColor, width: 1.px),
          textAlign: .center,
          position: .relative(),
        ),
        css('.quote-mark').styles(
          fontSize: 4.rem,
          fontWeight: .w800,
          color: primaryMid,
          lineHeight: 1.em,
          margin: .only(bottom: 0.5.rem),
          raw: {'opacity': '0.3'},
        ),
        css('.quote-text').styles(
          fontSize: 1.35.rem,
          fontStyle: .italic,
          color: textBlack,
          lineHeight: 1.6.em,
          margin: .only(bottom: 1.5.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.author-name').styles(
          fontSize: 1.1.rem,
          fontWeight: .w700,
          color: textBlack,
        ),
        css('.author-role').styles(
          fontSize: 0.9.rem,
          color: textDim,
          margin: .only(top: 0.2.rem),
        ),
      ]),
      css('.cons-cta-banner', [
        css('&').styles(
          width: 100.percent,
          maxWidth: 50.rem,
          padding: .symmetric(horizontal: contentPadding),
          boxSizing: .borderBox,
        ),
        css('.cons-cta-content').styles(
          display: .flex,
          flexDirection: .column,
          padding: .all(3.5.rem),
          backgroundColor: surface,
          radius: .circular(18.px),
          textAlign: .center,
          alignItems: .center,
        ),
        css('h2').styles(
          fontSize: 2.4.rem,
          fontWeight: .w800,
          margin: .only(top: 0.5.rem, bottom: 1.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('p').styles(
          maxWidth: 38.rem,
          fontSize: 1.15.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 2.2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.cons-contact-options').styles(
          display: .flex,
          flexWrap: .wrap,
          gap: .all(2.5.rem),
          justifyContent: .center,
          margin: .only(bottom: 2.5.rem),
        ),
        css('.contact-method').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          gap: .row(0.3.rem),
        ),
        css('.method-label').styles(
          fontSize: 0.8.rem,
          color: textDim,
          textTransform: .upperCase,
          letterSpacing: 0.05.em,
          fontWeight: .w600,
        ),
        css('.method-link').styles(
          fontSize: 1.15.rem,
          fontWeight: .w600,
          color: primaryMid,
        ),
        css('.cons-cta-buttons').styles(
          display: .flex,
          flexWrap: .wrap,
          gap: .all(1.rem),
          justifyContent: .center,
        ),
      ]),
    ]),
    css.media(.screen(maxWidth: 750.px), [
      css('.consulting-page .cons-hero h1').styles(fontSize: 2.3.rem),
      css('.consulting-page .cons-hero .cons-subtitle').styles(fontSize: 1.1.rem),
      css('.consulting-page .cons-section-header h2').styles(fontSize: 1.8.rem),
      css('.consulting-page .cons-cta-banner .cons-cta-content').styles(padding: .all(2.rem)),
      css('.consulting-page .cons-cta-banner h2').styles(fontSize: 1.8.rem),
    ]),
  ];
}
