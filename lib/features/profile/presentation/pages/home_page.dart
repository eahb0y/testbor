import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_event.dart';
import 'package:testbor/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:testbor/features/profile/presentation/bloc/profile_event.dart';
import 'package:testbor/features/profile/presentation/bloc/profile_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ProfileBloc>().add(const ProfileRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: () {
              context.read<AuthBloc>().add(const LoggedOut());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          switch (state.status) {
            case ProfileStatus.initial:
            case ProfileStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProfileStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Ошибка загрузки профиля',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          context.read<ProfileBloc>().add(
                            const ProfileRequested(),
                          );
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            case ProfileStatus.loaded:
              final profile = state.profile;
              if (profile == null) {
                return const Center(child: Text('Профиль не найден'));
              }
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _ProfileItem(label: 'ID', value: profile.id ?? '—'),
                  _ProfileItem(
                    label: 'Имя',
                    value: profile.fullName.isEmpty ? '—' : profile.fullName,
                  ),
                  _ProfileItem(label: 'Username', value: profile.username),
                  _ProfileItem(label: 'Телефон', value: profile.phone ?? '—'),
                  _ProfileItem(label: 'Email', value: profile.email ?? '—'),
                  _ProfileItem(label: 'Язык', value: profile.language),
                  _ProfileItem(
                    label: 'Роли',
                    value: profile.roles.isEmpty
                        ? '—'
                        : profile.roles.join(', '),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    );
  }
}
